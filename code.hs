import Data.List

-- two dimensional data structure in haskell
type Grid = Matrix Value
type Matrix a = [Row a]
type Row a = [a]
type Value = Char

-- easier way
-- type Grid = [[Char]]

balnk :: Grid
blank :: replicate 9 (replicate 9 '.')

rows :: Matrix a -> [Row a]
rows  = id -- using identity function `id x = x`
-- property: row . row = id

cols :: Matrix a -> [Row a]
cols = transpose
-- property: cols . cols = id

boxs :: Matrix a -> [Row a]

-- property: boxs . boxs = id
