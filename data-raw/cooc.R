ID1_cooc <- matrix(c(0,1,1,
                     1,0,1,
                     1,1,0), 3, 3, byrow = T,
                   dimnames = list(LETTERS[1:3], LETTERS[1:3]))
ID2_cooc <- matrix(c(0,1,1,
                     1,0,1,
                     1,1,0), 3, 3, byrow = T,
                   dimnames = list(LETTERS[1:3], LETTERS[1:3]))
ID3_cooc <- matrix(c(0,2,2,1,
                     2,0,1,0,
                     2,1,0,0,
                     1,0,0,0), 4, 4, byrow = T,
                   dimnames = list(LETTERS[1:4], LETTERS[1:4]))
cooc_dat <- list(ID1 = ID1_cooc,
                 ID2 = ID2_cooc,
                 ID3 = ID3_cooc)

usethis::use_data(cooc_dat, overwrite = TRUE)
