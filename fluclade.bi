model fluclade {

  param sigma
  param mu

  param initFreq
  
  state Freq

  noise n_freq

  obs zo
  
  sub transition {
    n_freq ~ wiener()
    Freq <- max(0, min(1, Freq + sigma * n_freq + mu))
  }
  
  sub parameter {
    sigma ~ uniform(0, 1)
    mu ~ uniform(0, 1)
  }

  sub initial {
    Freq <- initFreq
  }

  sub observation {
    zo ~ Freq**zo * (1-Freq) ** (1 - zo)
  }
}
