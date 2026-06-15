#include <mpi.h>
#include <hdf5.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>

#define NX 102     // global columns (includes boundaries)
#define NY 102     // global rows    (includes boundaries)
#define NG 1       // ghost rows above/below (allocated, not written)

/* Allocate a contiguous ny x nx 2D array */
static double **alloc2D(int ny, int nx) {
    double **a = (double **)malloc(ny * sizeof(*a));
    if (!a) return NULL;
    a[0] = (double *)malloc((size_t)ny * (size_t)nx * sizeof(**a));
    if (!a[0]) { free(a); return NULL; }
    for (int j = 1; j < ny; j++) a[j] = a[0] + (size_t)j * (size_t)nx;
    return a;
}

/* Parse exactly NX doubles from a line buffer using strtod safely */
static int parse_line_of_doubles(const char *line, double *out, int nx) {
    const char *p = line;
    char *endptr = NULL;
    int count = 0;
    while (count < nx) {
        while (*p==' '||*p=='\t'||*p=='\r') p++;
        if (*p=='\n' || *p=='\0') break;
        errno = 0;
        double v = strtod(p, &endptr);
        if (p == endptr) break;              // no conversion
        out[count++] = v;
        p = endptr;
    }
    return (count == nx) ? 0 : -1;
}

int main(int argc, char **argv) {
    MPI_Init(&argc, &argv);
    int rank=0, size=1;
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);

    const char *input  = "jacobi_010.dat";
    const char *output = "temperature_reconstructed.h5";

    // ------------------------------
    // 1) Row-wise decomposition
    // ------------------------------
    int base = NY / size;
    int rem  = NY % size;
    int local_rows = base + (rank < rem ? 1 : 0);
    int y_start    = rank * base + (rank < rem ? rank : rem);
    int y_end      = y_start + local_rows - 1;

    if (local_rows <= 0) {
        // In pathological cases size > NY
        local_rows = 0;
    }

    // Each rank allocates ghosts (not written)
    int ny_local_tot = local_rows + 2*NG;
    if (ny_local_tot <= 0) ny_local_tot = 2*NG;  // still allocate ghosts
    double **T = alloc2D(ny_local_tot, NX);
    if (!T) {
        fprintf(stderr, "Rank %d: alloc2D failed\n", rank);
        MPI_Abort(MPI_COMM_WORLD, 1);
    }

    // ------------------------------
    // 2) Parallel ASCII read (each rank reads only its rows)
    // ------------------------------
    FILE *fp = fopen(input, "r");
    if (!fp) {
        if (rank==0) fprintf(stderr, "Cannot open %s\n", input);
        MPI_Abort(MPI_COMM_WORLD, 2);
    }

    const size_t LBUF = (size_t)NX*32 + 256;
    char *line = (char *)malloc(LBUF);
    if (!line) {
        fprintf(stderr, "Rank %d: malloc line failed\n", rank);
        MPI_Abort(MPI_COMM_WORLD, 3);
    }

    // Skip lines before our first global row
    for (int j = 0; j < y_start; j++) {
        if (!fgets(line, (int)LBUF, fp)) {
            fprintf(stderr, "Rank %d: unexpected EOF skipping to row %d\n", rank, y_start);
            MPI_Abort(MPI_COMM_WORLD, 4);
        }
    }

    // Read our local_rows lines into T[NG .. NG+local_rows-1][0..NX-1]
    for (int j = 0; j < local_rows; j++) {
        if (!fgets(line, (int)LBUF, fp)) {
            fprintf(stderr, "Rank %d: unexpected EOF reading row %d\n", rank, y_start + j);
            MPI_Abort(MPI_COMM_WORLD, 5);
        }
        if (parse_line_of_doubles(line, &T[NG + j][0], NX) != 0) {
            fprintf(stderr, "Rank %d: parse error at global row %d\n", rank, y_start + j);
            MPI_Abort(MPI_COMM_WORLD, 6);
        }
    }
    fclose(fp);
    free(line);

    // (Optional) initialize ghost rows to something recognizable; NOT written.
    for (int i = 0; i < NX; i++) {
        T[0][i] = -999.0;                             // top ghost
        T[NG + local_rows][i] = -999.0;               // bottom ghost
    }

    // ------------------------------
    // 3) Parallel HDF5 write (collective)
    //    We write ONLY physical rows: exactly NY rows total.
    // ------------------------------
    MPI_Info info = MPI_INFO_NULL;
    hid_t fapl = H5Pcreate(H5P_FILE_ACCESS);
    H5Pset_fapl_mpio(fapl, MPI_COMM_WORLD, info);
    hid_t file = H5Fcreate(output, H5F_ACC_TRUNC, H5P_DEFAULT, fapl);
    
    H5Pclose(fapl);

    hsize_t gdim[2] = { (hsize_t)NY, (hsize_t)NX };
    hid_t filespace = H5Screate_simple(2, gdim, NULL);

    // File selection: our physical block (no ghosts)
    hsize_t start[2] = { (hsize_t)y_start, 0 };
    hsize_t count[2] = { (hsize_t)local_rows, (hsize_t)NX };

    // Guard (no overflow, even if size > NY)
    if (start[0] > (hsize_t)NY) count[0] = 0;
    if (start[0] + count[0] > (hsize_t)NY) count[0] = (hsize_t)NY - start[0];

    if (count[0] > 0)
        H5Sselect_hyperslab(filespace, H5S_SELECT_SET, start, NULL, count, NULL);
    else
        H5Sselect_none(filespace);

    // Memory selection: from buffer row NG (skip ghosts) for local_rows rows
    hsize_t memdim[2] = { (hsize_t)ny_local_tot, (hsize_t)NX };
    hid_t memspace = H5Screate_simple(2, memdim, NULL);

    hsize_t mem_start[2] = { (hsize_t)NG, 0 };
    if (count[0] > 0)
        H5Sselect_hyperslab(memspace, H5S_SELECT_SET, mem_start, NULL, count, NULL);
    else
        H5Sselect_none(memspace);

    // Create dataset and write collectively
    hid_t dset = H5Dcreate2(file, "/temperature", H5T_NATIVE_DOUBLE,
                            filespace, H5P_DEFAULT, H5P_DEFAULT, H5P_DEFAULT);

    hid_t dxpl = H5Pcreate(H5P_DATASET_XFER);
    H5Pset_dxpl_mpio(dxpl, H5FD_MPIO_COLLECTIVE);

    herr_t rc = H5Dwrite(dset, H5T_NATIVE_DOUBLE, memspace, filespace, dxpl, T[0]);
    if (rc < 0) {
        fprintf(stderr, "Rank %d: H5Dwrite failed (start[0]=%llu, count[0]=%llu)\n",
                rank, (unsigned long long)start[0], (unsigned long long)count[0]);
        MPI_Abort(MPI_COMM_WORLD, 7);
    }

    H5Pclose(dxpl);
    H5Sclose(memspace);
    H5Sclose(filespace);
    H5Dclose(dset);
    H5Fclose(file);

    // ------------------------------
    // 4) Cleanup
    // ------------------------------
    free(T[0]);
    free(T);

    if (rank == 0)
        printf("✅ Wrote %s with dataset /temperature of size 102x102.\n", output);

    MPI_Finalize();
    return 0;
}
