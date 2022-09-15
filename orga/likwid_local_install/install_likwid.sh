wget https://github.com/RRZE-HPC/likwid/archive/refs/tags/v5.2.2.tar.gz
tar -xf v5.2.2.tar.gz
cd likwid-5.2.2
cp ../config.mk .
make PREFIX=$HOME/.local
make install
cd ..
rm -rf likwid-5.2.2
rm v5.2.2.tar.gz
