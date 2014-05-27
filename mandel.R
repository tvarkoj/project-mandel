mandel.r <- function(w = 640, h = 480, start = complex(real = -1.8, imaginary = -1.2), end = complex(real = 0.6, imaginary = 1.2)) {
    
    iter <- function(c) {
        z <- complex(real = 0, imaginary = 0)
        for (n in 1:100) {
            re <- Re(z)
            im <- Im(z)
            if ((re * re + im * im) >= 4) {
                return (1 - n / 100)
            }
            z <- z * z + c
        }
        return (0)
    }

    delta = complex(real = (Re(end) - Re(start)) / w, imaginary = (Im(end) - Im(start)) / h)
        
    m <- matrix(0, h, w)
    
    for (row in 1:h) {
        for (col in 1:w) {
            c <- complex(real = Re(start) + Re(delta) * col, imaginary = Im(start) + Im(delta) * row)
            m[row, col] <- iter(c)
        }
    }
    m
}
    