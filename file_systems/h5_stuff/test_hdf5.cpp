// phdf5_write.cpp
#include <mpi.h>
#include <hdf5.h>
#include <vector>
#include <iostream>
#include <cstdlib>

int main(int argc, char** argv) {
    MPI_Init(&argc, &argv);

    int world_rank = -1, world_size = 0;
    MPI_Comm_rank(MPI_COMM_WORLD, &world_rank);
    MPI_Comm_size(MPI_COMM_WORLD, &world_size);

    // ----- Local data on each rank -----
    const hsize_t local_N = 100;                  // each rank owns 100 elements
    std::vector<double> v(local_N, 0.5 + world_rank); // make rank data distinct

    // ----- HDF5: set up file access property list for MPI-IO -----
    hid_t fapl = H5Pcreate(H5P_FILE_ACCESS);
    H5Pset_fapl_mpio(fapl, MPI_COMM_WORLD, MPI_INFO_NULL);

    // Create (truncate) file collectively
    hid_t file = H5Fcreate("out.h5", H5F_ACC_TRUNC, H5P_DEFAULT, fapl);
    H5Pclose(fapl);

    // ----- Create a 1-D dataset of size world_size * local_N (contiguous layout) -----
    const hsize_t global_N = local_N * static_cast<hsize_t>(world_size);
    hid_t filespace = H5Screate_simple(1, &global_N, nullptr);

    // Dataset creation property list (default contiguous; no compression for MPI)
    hid_t dcpl = H5Pcreate(H5P_DATASET_CREATE);
    hid_t dset = H5Dcreate2(file, "/data", H5T_NATIVE_DOUBLE, filespace,
                            H5P_DEFAULT, dcpl, H5P_DEFAULT);
    H5Pclose(dcpl);
    H5Sclose(filespace);

    // ----- Select this rank's hyperslab in the file -----
    const hsize_t offset = world_rank * local_N; // where this rank starts
    const hsize_t count  = local_N;

    hid_t file_space_sel = H5Dget_space(dset);
    H5Sselect_hyperslab(file_space_sel, H5S_SELECT_SET, &offset, nullptr, &count, nullptr);

    // Memory space matches our local buffer shape
    hid_t memspace = H5Screate_simple(1, &count, nullptr);

    // ----- Use collective I/O for the write -----
    hid_t dxpl = H5Pcreate(H5P_DATASET_XFER);
    H5Pset_dxpl_mpio(dxpl, H5FD_MPIO_COLLECTIVE);

    // Write collectively
    herr_t status = H5Dwrite(dset, H5T_NATIVE_DOUBLE, memspace, file_space_sel, dxpl, v.data());
    if (status < 0 && world_rank == 0) {
        std::cerr << "H5Dwrite failed\n";
    }

    // Clean up
    H5Pclose(dxpl);
    H5Sclose(memspace);
    H5Sclose(file_space_sel);
    H5Dclose(dset);

    // (Optional) Ensure data is on disk before close
    H5Fflush(file, H5F_SCOPE_GLOBAL);
    H5Fclose(file);

    MPI_Barrier(MPI_COMM_WORLD);
    if (world_rank == 0) std::cout << "Wrote out.h5 with " << global_N << " doubles\n";

    MPI_Finalize();
    return 0;
}
