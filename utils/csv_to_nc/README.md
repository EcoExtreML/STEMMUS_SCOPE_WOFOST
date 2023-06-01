# Converting `.csv` files to NetCDF files

Currently, model outputs are several files in `csv` format. The model output
should be converted to one netcedf file according to Plumber protocol. To do so,
there is a file
[Variables_will_be_in_NetCDF_file.csv](./Variables_will_be_in_NetCDF_file.csv.
The file lists variables that should be in the netcdf file. Also, there is a
python script [csv_to_nc.py](./csv_to_nc.py) that contains main fucntions. Below
we explain how to use the python scripts.

## 1. Create Conda environment

> We need to do this step only once.

We download and install Conda:

```sh
wget https://github.com/conda-forge/miniforge/releases/latest/download/Mambaforge-pypy3-Linux-x86_64.sh
bash Mambaforge-pypy3-Linux-x86_64.sh -b -p ~/mamba
```

Then, update base environment:

```sh
. ~/mamba/bin/activate
mamba update --name base mamba
```

Finally, we create new conda environment called 'stemmus' with all required dependencies:

```sh
cd STEMMUS_SCOPE/utils/csv_to_nc
mamba env create
```

## 2. Activate Conda environment

> We need to do this step before running our python scripts.

The environment can be activated with

```sh
. ~/mamba/bin/activate stemmus
```

## 3. Run python script

Open the configuration file [config_file_crib.txt][../../config_file_crib.txt]
or [config_file_snellius.txt][../../config_file_snellius.txt] and edit paths. Then,

```sh
cd STEMMUS_SCOPE
python utils/csv_to_nc/generate_netcdf_files.py --config_file config_file_crib.txt --variable_file utils/csv_to_nc/Variables_will_be_in_NetCDF_file.csv
```

This will generate `ECdata.csv` and a netcdf file related to model output.