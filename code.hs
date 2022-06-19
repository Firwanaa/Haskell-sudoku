import Data.List

-- two dimensional data structure in haskell
type Grid = Matrix Value
type Matrix a = [Row a]
type Row a = [a]
type Value = Char

-- breakdown
-- type Grid = Matrix Value
--           = [Row Value]
--           = [[Value]]
--           = [[Char]
-- easier way
-- type Grid = [[Char]]

blank :: Grid
blank = replicate 9 (replicate 9 '.')

-- Solvable only using the basic rules:
easy                  :: Grid
easy                  =  ["2....1.38",
                          "........5",
                          ".7...6...",
                          ".......13",
                          ".981..257",
                          "31....8..",
                          "9..8...2.",
                          ".5..69784",
                          "4..25...."]

-- First gentle example from sudoku.org.uk:

gentle                :: Grid
gentle                =  [".1.42...5",
                          "..2.71.39",
                          ".......4.",
                          "2.71....6",
                          "....4....",
                          "6....74.3",
                          ".7.......",
                          "12.73.5..",
                          "3...82.7."]

-- First diabolical example:

diabolical            :: Grid
diabolical            =  [".9.7..86.",
                          ".31..5.2.",
                          "8.6......",
                          "..7.5...6",
                          "...3.7...",
                          "5...1.7..",
                          "......1.9",
                          ".2.6..35.",
                          ".54..8.7."]

-- First "unsolvable" (requires backtracking) example:

unsolvable            :: Grid
unsolvable            =  ["1..9.7..3",
                          ".8.....7.",
                          "..9...6..",
                          "..72.94..",
                          "41.....95",
                          "..85.43..",
                          "..3...7..",
                          ".5.....4.",
                          "2..8.6..9"]

-- Minimal sized grid (17 values) with a unique solution:
minimal               :: Grid
minimal               =  [".98......",
                          "....7....",
                          "....15...",
                          "1........",
                          "...2....9",
                          "...9.6.82",
                          ".......3.",
                          "5.1......",
                          "...4...2."]

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

type Choices          =  [Value]

choices               :: Grid -> Matrix Choices
choices               =  map (map choice)
                         where
                            choice v = if empty v then values else [v] -- values = ['1'..'9']
-- choices g = map (map choice) g
-- cartesian product of list of lists
cp                    :: [[a]] -> [[a]]
cp []                 =  [[]]
cp (xs:xss)           =  [y:ys | y <- xs, ys <- cp xss] -- recursively processing the tail

collapse              :: Matrix [a] -> [Matrix a]
collapse              =  cp . map cp -- collapse matrix = cp (map cp matrix)

solve :: Grid -> [Grid]
solve = filter valid . collapse . choices -- using function composition
-- solve grid = filter valid (collapse (choices g))

prune  :: Matrix Choices -> Matrix Choices
prune  = pruneBy boxs . pruneBy cols . pruneBy rows
        where pruneBy f = f . map reduce . f

reduce     :: Row Choices -> Row Choices
reduce xss = [xs `minus` singles | xs <- xss]
             where singles = concat (filter single xss)

minus :: Choices -> Choices -> Choices
xs `minus` ys = if single xs then xs else xs \\ ys

solve2                :: Grid -> [Grid]
solve2                =  filter valid . collapse . prune . choices

solve3                :: Grid -> [Grid]
solve3                =  filter valid . collapse . fix prune . choices

fix                   :: Eq a => (a -> a) -> a -> a
fix f x               =  if x == x' then x else fix f x'
                         where x' = f x

complete              :: Matrix Choices -> Bool
complete              =  all (all single)


void                  :: Matrix Choices -> Bool
void                  =  any (any null)

safe                  :: Matrix Choices -> Bool
safe cm               =  all consistent (rows cm) &&
                         all consistent (cols cm) &&
                         all consistent (boxs cm)

consistent            :: Row Choices -> Bool
consistent            =  nodups . concat . filter single

blocked               :: Matrix Choices -> Bool
blocked m             =  void m || not (safe m)
