{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE NoImplicitPrelude #-}

module Main
  ( main,
  )
where

import Data.Morpheus.Types (GQLRequest (..), GQLResponse (..))
import qualified Feature.Collision.CategoryCollisionFail as TypeCategoryCollisionFail
import qualified Feature.Collision.CategoryCollisionSuccess as TypeCategoryCollisionSuccess
import qualified Feature.Collision.NameCollision as NameCollision
import qualified Feature.Holistic.API as Holistic
import qualified Feature.Inference.TaggedArguments as TaggedArguments
import qualified Feature.Inference.TaggedArgumentsFail as TaggedArgumentsFail
import qualified Feature.Inference.TypeGuards as TypeGuards
import qualified Feature.Inference.TypeInference as TypeInference
import qualified Feature.Inference.UnionType as UnionType
import qualified Feature.Inference.WrappedType as WrappedType
import qualified Feature.Input.DefaultValues as DefaultValues
import qualified Feature.Input.Enums as Enums
import qualified Feature.Input.Objects as Objects
import qualified Feature.Input.Scalars as Scalars
import qualified Feature.Input.Variables as Variables
import Relude
import Rendering.TestSchemaRendering (testSchemaRendering)
import Subscription.Test (testSubscriptions)
import Test.Morpheus
  ( FileUrl,
    cd,
    mainTest,
    mkUrl,
    scan,
    testApi,
  )
import Test.Tasty
  ( TestTree,
    testGroup,
  )

mkFeatureUrl :: FilePath -> FilePath -> FileUrl
mkFeatureUrl groupName = cd (cd (mkUrl "Feature") groupName)

testFeature :: FilePath -> (GQLRequest -> IO GQLResponse, FilePath) -> IO TestTree
testFeature groupName (api, name) = scan (testApi api) (mkFeatureUrl groupName name)

testFeatures :: FilePath -> [(GQLRequest -> IO GQLResponse, FilePath)] -> IO TestTree
testFeatures name cases =
  testGroup name
    <$> traverse
      (testFeature name)
      cases

main :: IO ()
main =
  mainTest
    "Morpheus Graphql Tests"
    [ testFeatures
        "Input"
        [ (Variables.api, "variables"),
          (Enums.api, "enums"),
          (Scalars.api, "scalars"),
          (Objects.api, "objects"),
          (DefaultValues.api, "default-values")
        ],
      testFeatures
        "Collision"
        [ (TypeCategoryCollisionSuccess.api, "category-collision-success"),
          (TypeCategoryCollisionFail.api, "category-collision-fail"),
          (NameCollision.api, "name-collision")
        ],
      testFeatures
        "Inference"
        [ (WrappedType.api, "wrapped-type"),
          (TypeGuards.api, "type-guards"),
          (UnionType.api, "union-type"),
          (TypeInference.api, "type-inference"),
          (TaggedArguments.api, "tagged-arguments"),
          (TaggedArgumentsFail.api, "tagged-arguments-fail")
        ],
      testFeatures
        "Holistic"
        [ (Holistic.api, "holistic")
        ],
      testSubscriptions,
      pure testSchemaRendering
    ]
