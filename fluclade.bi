model fluclade {

  param sigma
  param mu

  state Freq

  noise n_freq

  obs zo
  
  sub transition {
    n_freq ~ wiener()
    Freq <- max(0.01, min(0.99, Freq + sigma * n_freq + mu))
  }
  
  sub parameter {
    sigma ~ uniform(lower = 0, upper = 0.5)
    mu ~ uniform(lower = 0, upper = 0.5)
  }

  sub proposal_parameter {
    sigma ~ truncated_gaussian(mean = sigma, std = 0.01, lower = 0, upper = 0.5)
    mu ~ truncated_gaussian(mean = mu, std = 0.1, lower = 0, upper = 0.5)
  }

  sub proposal_initial {
    Freq ~ truncated_gaussian(mean = Freq, std = 0.1, lower = 0, upper = 0.1)
  }

  sub initial {
    Freq ~ uniform()
  }

  sub observation {
    zo ~ (Freq ** zo) * ((1-Freq) ** (1 - zo))
  }
}
