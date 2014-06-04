all: mandel.so

clean:
	rm -f *.so
	rm -f *.o

mandel.so: mandel_cpu.o mandel_gpu.o
	clang -dynamiclib  -framework R -rpath /usr/local/cuda/lib -L/usr/local/cuda/lib -lcudart -o mandel.so mandel_cpu.o mandel_gpu.o 

mandel_cpu.o: mandel_cpu.c
	nvcc -ccbin /usr/bin/clang -arch=sm_30 -I/Library/Frameworks/R.framework/Resources/include -DNDEBUG -g -O2 -c mandel_cpu.c -o mandel_cpu.o

mandel_gpu.o: mandel_gpu.cu
	nvcc -ccbin /usr/bin/clang -arch=sm_30 -I/Library/Frameworks/R.framework/Resources/include -DNDEBUG -g -O2 -c mandel_gpu.cu -o mandel_gpu.o
