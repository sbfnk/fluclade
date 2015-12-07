############################################################################
## Test for clade frequency estimation                                    ##
############################################################################

if (!file.exists("fluclade.bi")) {
    stop("Error: can't find model file 'fluclade.bi'. Please run this from a directory where 'fluclade.bi' exists.")
}

library('docopt')

"Script for testing a model for frequency estimation of clades
Usage: test_clades.r [options]
Options:
-s --sigma=<sigma>                  Volatility (default: random number [0, 0.05])
-m --mu=<mu>                        Drift (default: random number [-0.01, 0.01])
-i --init=<init>                    Initial frequency (default: random number [0.3, 0.7])
-N --ndata=<ndata>                  Number of data points to generate (default: 20)
-n --nsamples                       Number of samples to generate (default: 10000)
-d --seed=<seed>                    Random seed
-o --output-file=<output.file>      Output file base (default: 'freq'); suffixes will be attached
-w --working-directory=<work.dir>   Working directory (default: './libbi')
-v --verbose                        Verbose output
-h --help                           show this message" -> doc

## read arguments
opts <- docopt(doc)

if (opts[["help"]])
{
    print(opts)
    exit()
}

if ("sigma" %in% opts)
{
    sigma <- as.numeric(opts[["sigma"]])
} else
{
    sigma <- runif(1, min = 0, max = 0.05)
}

if ("mu" %in% opts)
{
    mu <- as.numeric(opts[["mu"]])
} else
{
    mu <- runif(1, min = -0.01, max = 0.01)
}

if ("init" %in% opts)
{
    freq <- as.numeric(opts[["init"]])
} else
{
    freq <- runif(1, min = 0.3, max = 0.7)
}

if ("ndata" %in% opts)
{
    N <- as.integer(opts[["ndata"]])
} else
{
    N <- 20
}

if ("nsamples" %in% opts)
{
    nsamples <- as.integer(opts[["nsamples"]])
} else
{
    nsamples <- 10000
}

if ("output-file" %in% opts)
{
    output_file_base <- opts[["output-file"]]
} else
{
    output_file_base <- "freq"
}
    
if ("working-directory" %in% opts)
{
    work_dir <- opts[["working-directory"]]
} else
{
    work_dir <- "libbi"
}

if ("seed" %in% opts) set.seed(opts[["seed"]])

suppressWarnings(dir.create(work_dir))
unlink(work_dir, recursive = TRUE)
dir.create(work_dir)

library('RBi')
library('RBi.helpers')
library('cowplot')

message("Generating data")
message("  Initial frequency: ", round(freq, 2))
message("  Volatility: ", round(sigma, 3))
message("  drift: ", round(mu, 3))
message("")

## generate data points
dp <- c()
freqs <- c()
for (i in seq_len(N))
{
    freqs <- c(freqs, freq)
    ## Bernoulli random draw
    dp <- c(dp, as.integer(runif(1) < freq))
    ## update frequency
    freq <- max(0, min(1, freq + rnorm(1, sd = sigma) + mu))
}

## take four times the smallest power of 2 < (2 * N) as number of particles
nparticles <- 4 * 2 ** ceiling(log(N, base = 2))

## run libbi
options <- list(noutputs = length(dp) - 1,
                "start-time" = 0,
                "end-time" = length(dp) - 1,
                nparticles = nparticles,
                nsamples = nsamples,
                seed = runif(1, max = .Machine$integer.max))

bi_wrapper <- libbi(client = "sample",
                    model_file_name = "fluclade.bi",
                    global_options = options,
                    working_folder = work_dir)

bi_wrapper$run(obs = list(zo = dp), verbose = opts[["verbose"]])

## analyse results
res <- bi_read(bi_wrapper)
rdt <- lapply(res, data.table)

state_samples <- rdt$Freq
initFreq <- rdt$Freq[nr == 0]
initFreq[, nr := NULL]

setnames(state_samples, c("nr", "np"), c("time", "iteration"))
write.table(state_samples, paste0(output_file_base, "_state_samples.csv"), sep = ",",
            quote = FALSE, row.names = FALSE)

setnames(rdt$sigma, "value", "sigma")
setnames(rdt$mu, "value", "mu")
setnames(initFreq, "value", "init")

parameter_samples <- merge(rdt$sigma, rdt$mu, by = c("np"))
parameter_samples <- merge(parameter_samples, initFreq, by = c("np"))
setnames(parameter_samples, "np", "iteration")
write.table(parameter_samples, paste0(output_file_base, "_param_samples.csv"), sep = ",",
            quote = FALSE, row.names = FALSE)

params <- data.table(name = c("sigma", "mu", "init"),
                    values = c(sigma, mu, freqs[1]))
write.table(params, paste0(output_file_base, "_params.csv"), sep = ",",
            quote = FALSE, row.names = FALSE)

sim_data <- data.table(time = seq_along(freqs) - 1, freq = freqs, data = dp)
write.table(sim_data, paste0(output_file_base, "_data.csv"), sep = ",",
            quote = FALSE, row.names = FALSE)

p <- plot_libbi(res, trend = "mean", data = sim_data[, list(time, value = freq)])
plot <- p$states +
    geom_point(data = sim_data, aes(x = time, y = data), color = "black", shape = 4)
save_plot(paste0(output_file_base, ".pdf"), plot)
