model fluclade {

  param sigma
  param mu

  state Freq

  noise n_freq

  obs zo
  
  sub transition {
    n_freq ~ wiener()
    Freq <- max(0, min(1, Freq + sigma * n_freq + mu))
  }
  
  sub parameter {
    sigma ~ uniform()
    mu ~ uniform()
  }

  sub proposal_parameter {
    sigma ~ truncated_gaussian(mean = sigma, std = 0.05, lower = 0, upper = 1)
    mu ~ truncated_gaussian(mean = sigma, std = 0.05, lower = 0, upper = 1)
  }

  sub proposal_initial {
    Freq ~ truncated_gaussian(mean = Freq, std = 0.05, lower = 0, upper = 1)
  }

  sub initial {
    Freq ~ uniform()
  }

  sub observation {
    zo ~ (Freq ** zo) * ((1-Freq) ** (1 - zo))
  }
}
