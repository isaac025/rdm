module Expressions where

import Data.List.NonEmpty (NonEmpty)
import Data.Text.Lazy (Text)
import Data.Void (Void)
import Numeric.Natural
import Prettyprinter

data Module = Module
    { moduleName :: Text
    , declarations :: [Declaration]
    , extension :: Maybe Text
    }

instance Pretty Module where
    pretty (Module mname decls mext) =
        let decls' = if isTypes decls then typeDecls decls else []
         in case mext of
                Nothing -> pretty mname <+> vsep [" = ", "class", pretty decls', "end"]
                Just ext -> pretty (mname <> " = ") <+> hsep ["extend " <> pretty ext <> " with "] <+> vsep ["class", "end"]
      where
        isTypes :: [Declaration] -> Bool
        isTypes ((TypeDecl _) : _) = True
        isTypes _ = False

        typeDecls :: [Declaration] -> [TypeDeclaration]
        typeDecls [] = []
        typeDecls ((TypeDecl ds) : xs) = ds ++ typeDecls xs
        typeDecls (_ : xs) = typeDecls xs

data Declaration
    = TypeDecl [TypeDeclaration]
    | ValueDecl (NonEmpty ValueDeclaration)
    | AxiomDecl (NonEmpty AxiomDeclaration)

data TypeDeclaration
    = Sort Text
    | AbstractType Text TypeExpr

instance Pretty TypeDeclaration where
    pretty (Sort text) = pretty text
    pretty (AbstractType text (TypeTE t)) = pretty text <+> pretty t
    pretty (AbstractType text _) = pretty text

data Type
    = NatT
    | BoolT
    | IntT
    | RealT
    | CharT
    | TextT
    | UnitT
    | AdtT Text
    deriving (Eq)

instance Pretty Type where
    pretty NatT = pretty ("Nat" :: Text)
    pretty BoolT = pretty ("Bool" :: Text)
    pretty IntT = pretty ("Int" :: Text)
    pretty RealT = pretty ("Real" :: Text)
    pretty CharT = pretty ("Char" :: Text)
    pretty TextT = pretty ("Text" :: Text)
    pretty UnitT = pretty ("()" :: Text)
    pretty (AdtT text) = pretty text

data TypeExpr
    = TypeTE Type
    | SetTE Type
    | ProductTE (NonEmpty TypeExpr)
    | TotalFuncTE TypeExpr TypeExpr
    | PartialFuncTE TypeExpr TypeExpr
    | AppTE Text [ValueExpr] Text ValueExpr ValueExpr

data ValueDeclaration = ValueDeclaration
    { valueIdentifier :: Text
    , valueTypeExpr :: TypeExpr
    }

type TypingList = NonEmpty ValueDeclaration -- typing same as a value declaration

data AxiomDeclaration = AxiomDeclaration
    { axiomNaming :: Maybe Text
    , axiomValueExpr :: NonEmpty ValueExpr
    }

data ValueExpr
    = BoolVE Bool
    | If ValueExpr ValueExpr (Maybe [ValueExpr]) ValueExpr
    | NotVE ValueExpr
    | BinOpVE ValueBinOp ValueExpr ValueExpr
    | ChaosVE Void
    | QuantVE Quantifier TypingList ValueExpr
    | IntVE Int
    | Abs ValueExpr
    | NatVE Natural
    | RealVE Double
    | CharVE Char
    | TextVE Text
    | UnitVE ()
    | ProductVE (NonEmpty ValueExpr)
    | AppVE Text [ValueExpr]
    | Pre ValueExpr
    | FuncVE TypingList ValueExpr
    | Post ValueExpr

data ValueBinOp
    = Equal
    | NotEqual
    | Is
    | IsIn
    | Union
    | And
    | Or
    | Impl
    | Gt
    | GtEq
    | Lt
    | LtEq
    | Add
    | Sub
    | Mul
    | Div
    | Rem
    | Exp

data Quantifier = Forall | Exists | ExistsOne
