#
#
#
# First, naive implementation in pure R
#
#
#

mandel.r <- function(w = 320, h = 200, start = complex(real = -1.8, imaginary = -1.2), end = complex(real = 0.6, imaginary = 1.2)) {
    
    iter <- function(c) {
        z <- complex(real = 0, imaginary = 0)
        for (n in 1:200) {
            re <- Re(z)
            im <- Im(z)
            if ((re * re + im * im) >= 4) {
                return (1 - n / 200)
            }
            z <- z * z + c
        }
        return (0)
    }

    delta = complex(real = (Re(end) - Re(start)) / w, imaginary = (Im(end) - Im(start)) / h)
        
    m <- matrix(0, h, w)
    
    for (row in 1:h) {
        for (col in 1:w) {
            c <- complex(real = Re(start) + Re(delta) * (col - 1), imaginary = Im(start) + Im(delta) * (row - 1))
            m[row, col] <- iter(c)
        }
    }
    m
}

#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
# C-based implementation
#
#
#


mandel.cpu <- function(w = 320, h = 200, start = complex(real = -1.8, imaginary = -1.2), end = complex(real = 0.6, imaginary = 1.2)) {
    res <- .C("mandel_cpu", as.integer(w), as.integer(h), as.double(Re(start)), as.double(Re(end)), as.double(Im(start)), as.double(Im(end)), result = double(w * h))
    matrix(res[["result"]], nrow = h, ncol = w)
}

#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
# CUDA-based implementation
#
#
#

mandel.gpu <- function(w = 320, h = 200, start = complex(real = -1.8, imaginary = -1.2), end = complex(real = 0.6, imaginary = 1.2)) {
    res <- .C("mandel_gpu", as.integer(w), as.integer(h), as.double(Re(start)), as.double(Re(end)), as.double(Im(start)), as.double(Im(end)), result = double(w * h))
    matrix(res[["result"]], nrow = h, ncol = w)
}

#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
# some helpers
# 
#
#
#

capture.stat <- function() {
    df <- data.frame()
    # warmup
    mandel.gpu()
    mandel.cpu()
    for (i in seq(800, 7200, 800)) {
        print(sprintf("Processing CPU code for %dx%d", i, i));
        cpu <- system.time(mandel.cpu(i, i))[['elapsed']]
        print(sprintf("Processing GPU code for %dx%d", i, i));
        gpu <- system.time(mandel.gpu(i, i))[['elapsed']]
        df1 <- data.frame(size=i, cpu=cpu, gpu=gpu)
        df <- rbind(df, df1)
    }
    df
}

show.stat <- function(stat) {
    plot(stat$size, stat$cpu, t="l", col="blue", xlab="size", ylab="elapsed (sec)")
    lines(stat$size, stat$gpu, col="red")
    legend("topleft", c("CPU", "GPU"), lty = 1, col=c("blue", "red"))  
}