
-- ---------------------------------------------------------------------------------------------- --

module Tgf

( tgf2staut
)

where

import qualified Data.Map.Strict           as Map
import           Text.Read
import qualified Text.PortableLines        as PL


-- ---------------------------------------------------------------------------------------------- --

type States = Map.Map Int String


tgf2staut :: String -> Either String String
tgf2staut tgf  =  case tgfNodes Map.empty False (PL.lines tgf) of
                    Left  err    -> Left  $ err
                    Right lines' -> Right $ unlines lines'


tgfNodes :: States -> Bool -> [String] -> Either String [String]
tgfNodes states False []            =  Left "STAUTDEF and symbol '#' missing"
tgfNodes states True  []            =  Left "symbol '#' missing"
tgfNodes states False ("#":lines)   =  Left "STAUTDEF missing"
tgfNodes states True  ("#":lines)   =  tgfEdges states lines
tgfNodes states sdef  (line:lines)
 =  case (sdef,words line) of
      (True ,n:"STAUTDEF":ws) -> Left "STAUTDEF twice"
      (False,n:"STAUTDEF":ws) -> case (formatSDef line,tgfNodes states True lines) of
                                   (Left  err1  ,Left  err2   ) -> Left $ err1 ++ ", " ++ err2
                                   (Right lines',Right lines'') -> Right $ lines' ++ lines''
      (sdef,[node,name])      -> case ((readMaybe node)::(Maybe Int),name `elem` (Map.elems states)) of
                                 (Nothing,False) -> Left "invalid node number"
                                 (Nothing,True ) -> Left "invalid node number, double state name"
                                 (Just nr,True ) -> Left "double state name"
                                 (Just nr,False) -> tgfNodes (Map.insert nr name states) sdef lines
      _                        -> Left $ "invalid list of states" ++ "\n" ++
                                         (show line)  ++ "\n" ++
                                         (show lines)  ++ "\n" ++
                                         (show $ words line)  ++ "\n"         


tgfEdges :: States -> [String] -> Either String [String]
tgfEdges states [] = Right ["ENDDEF",""]
tgfEdges states (line:lines) =  case tgfEdges states lines of
                                  Left err     -> Left err
                                  Right lines' -> case formatTrans states line of
                                                    Left  err   -> Left  err
                                                    Right line' -> Right $ line' : lines'


formatSDef :: String -> Either String [String]
formatSDef line
 =  let (line0,rest0) = break (`elem`   ["STAUTDEF"          ]) (words line)
        (line1,rest1) = break (`elem`   ["::="               ]) rest0
        (line2,rest2) = break (`elem`   ["STATE","VAR","INIT"]) rest1
        (line3,rest3) = break (`notElem`["STATE","VAR","INIT"]) rest2
        (line4,rest4) = break (`elem`   ["STATE","VAR","INIT"]) rest3
        (line5,rest5) = break (`notElem`["STATE","VAR","INIT"]) rest4
        (line6,rest6) = break (`elem`   ["STATE","VAR","INIT"]) rest5
        (line7,rest7) = break (`notElem`["STATE","VAR","INIT"]) rest6
        (line8,rest8) = break (`elem`   ["STATE","VAR","INIT"]) rest7
        line9         = ["TRANS"]
     in
        if rest8 /= []
          then Left "wrong syntax STAUTDEF"
          else Right [ ""
                     , (unwords line1)
                     , "  " ++ (unwords line2)
                     , "    " ++ (unwords line3)
                     , "        " ++ (unwords line4)
                     , "    " ++ (unwords line5)
                     , "        " ++ (unwords line6)
                     , "    " ++ (unwords line7)
                     , "        " ++ (unwords line8)
                     , "    " ++ (unwords line9)
                     ]


formatTrans :: States -> String -> Either String String
formatTrans states line
 =  case words line of
      n1:n2:ws -> case ((readMaybe n1)::(Maybe Int),(readMaybe n2)::(Maybe Int)) of
                    (Nothing,_) -> Left "invalid state number in transition"
                    (_,Nothing) -> Left "invalid state number in transition"
                    (Just nr1,Just nr2)
                                -> case (Map.lookup nr1 states,Map.lookup nr2 states) of
                                     (Nothing,_)       -> Left  "non-existent state in transition"
                                     (_,Nothing)       -> Left  "non-existent state in transition"
                                     (Just s1,Just s2) -> Right $ "        " ++ s1 ++ "  ->  " ++
                                                            (unwords ws) ++ "  ->  " ++ s2


-- ---------------------------------------------------------------------------------------------- --
--                                                                                                --
-- ---------------------------------------------------------------------------------------------- --

