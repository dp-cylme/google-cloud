{-# LANGUAGE DeriveGeneric     #-}
{-# LANGUAGE OverloadedStrings #-}

module Google.Cloud.Compute.Projects where

import           Blaze.ByteString.Builder    (Builder)
import           Control.Monad.Except        (MonadError (..))
import           Data.Aeson                  (FromJSON, eitherDecode)
import           Data.Monoid                 ((<>))
import           Data.Text                   (Text)
import           GHC.Generics                (Generic)
import           Network.HTTP.Types          (encodePath)

import           Google.Cloud.Compute.Types
import           Google.Cloud.Internal.HTTP
import           Google.Cloud.Internal.Token
import           Google.Cloud.Internal.Types

data ProjectResource = ProjectResource
    { kind                   :: Text
    , creationTimestamp      :: Text
    , name                   :: Text
    , commonInstanceMetadata :: Metadata
    , quotas                 :: [Quota]
    , selfLink               :: Text
    , defaultServiceAccount  :: Text
    } deriving (Generic)

instance FromJSON ProjectResource

getProject :: ProjectId -> Cloud ProjectResource
getProject projectId = do
    authH <- authorizationHeader
    getJSON url [authH]
  where
    url = computeUrl <> encodePath ["projects", unProjectId projectId] []


setCommonInstanceMetadata :: ProjectId -> [Item] -> Cloud Result
setCommonInstanceMetadata projectId itms = do
    authH <- authorizationHeader
    pr <- getProject projectId
    postJSON url [authH] (body pr) >>=
        \res ->
             case eitherDecode res of
                 Left err -> throwError (DecodeError err)
                 Right res' -> return res'
  where
    url =
        computeUrl <>
        encodePath
            ["projects", unProjectId projectId, "setCommonInstanceMetadata"]
            []
    body pr =
        (Metadata
             "compute#metadata"
             (fingerprint (commonInstanceMetadata pr))
             (items (commonInstanceMetadata pr) ++ itms))

computeUrl :: Builder
computeUrl = "https://www.googleapis.com/compute/beta"
