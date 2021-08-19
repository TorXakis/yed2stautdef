
-- ---------------------------------------------------------------------------------------------- --

module Main

where

import           System.Environment          (getArgs)
import           System.IO
import           Data.List

import           Tgf


-- ---------------------------------------------------------------------------------------------- -- 27

main ::  IO ()
main  =  do

    hSetBuffering stdin  NoBuffering   -- alt: LineBuffering
    hSetBuffering stdout NoBuffering   -- alt: LineBuffering
    hSetBuffering stderr NoBuffering   -- alt: LineBuffering
--    hSetEncoding stdin  latin1
--    hSetEncoding stdout latin1
--    hSetEncoding stderr latin1

    args <- getArgs
    if and [ ".tgf" `isSuffixOf` arg | arg <- args ]
      then do loop args
      else do hPutStrLn stderr $ "arguments must be .tgf files"


-- ---------------------------------------------------------------------------------------------- --

loop :: [String] -> IO ()
loop args  =  do

    case args of
      []         -> do return ()
      (arg:args) -> do tgf <- readFile arg
                       case tgf2staut tgf of
                         Left err    -> do hPutStrLn stderr $ arg ++ ": parse error: " ++ err
                                           loop args
                         Right staut -> do let txsfile = (take (length arg - 4) arg) ++ ".txs"
                                           txsh <- openFile txsfile WriteMode
                                           hPutStr txsh staut
                                           hClose txsh
                                           loop args


-- ---------------------------------------------------------------------------------------------- --
--                                                                                                --
-- ---------------------------------------------------------------------------------------------- --

