#include <R.h>

#define ITERATIONS 200

typedef struct {
    double re;
    double im;
} complex;

complex zero()
{
    complex res;
    res.re = 0.0;
    res.im = 0.0;
    return res;
}

complex add(complex a, complex b) 
{
    complex res;
    res.re = a.re + b.re;
    res.im = a.im + b.im;
    return res;
}

complex mul(complex a, complex b)
{
    complex res;
    res.re = a.re * b.re - a.im * b.im;
    res.im = a.re * b.im + a.im * b.re;
    return res;
}

double square_mod(complex c)
{
    return c.re * c.re + c.im * c.im;
}

double color(complex c)
{
    complex z = zero();
    for (int i = 1; i <= ITERATIONS; ++i) {
        if (square_mod(z) >= 4.0) {
            return (1.0 - (double)i / ITERATIONS);
        }
        z = add(mul(z, z), c);
    }
    return 0.0;
}

void mandel_cpu(int *w, int *h, double *sr, double *er, double *si, double *ei, double *result) 
{
    double dr = (*er - *sr) / *w;
    double di = (*ei - *si) / *h;

    for (int row = 0; row < *h; ++row) {
        for (int col = 0; col < *w; ++col) {
            complex c;
            c.re = *sr + dr * col;
            c.im = *si + di * row;
            result[row + col * (*h)] = color(c);
        }
    }
}


