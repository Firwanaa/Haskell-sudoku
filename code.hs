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

boxsize               :: Int
boxsize               =  3

values                :: [Value]
values                =  ['1'..'9']

empty                 :: Value -> Bool
empty                 =  (== '.')

single                :: [a] -> Bool
single [_]            =  True
single _              =  False

rows :: Matrix a -> [Row a]
rows  = id -- using identity function `id x = x`
-- property: row . row = id

cols :: Matrix a -> [Row a]
cols = transpose
-- property: cols . cols = id
boxs                  :: Matrix a -> [Row a]
boxs                  =  unpack . map cols . pack
                         where
                            pack   = split . map split
                            split  = chop boxsize
                            unpack = map concat . concat

chop                  :: Int -> [a] -> [[a]]
chop n []             =  []
chop n xs             =  take n xs : chop n (drop n xs)

-- property: boxs . boxs = id

valid                 :: Grid -> Bool
valid g               =  all nodups (rows g) &&
                         all nodups (cols g) &&
                         all nodups (boxs g)

nodups                :: Eq a => [a] -> Bool
nodups []             =  True
nodups (x:xs)         =  not (elem x xs) && nodups xs -- nice
