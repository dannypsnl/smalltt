{-# language UnboxedTuples #-}

module GenTestFiles where

replace :: String -> String -> String
replace x =
  foldr (\c s -> case c of '%' -> x ++ s; _ -> c:s) []

times :: (Int -> String) -> Int -> String
times f n = concatMap f [0..n-1]

test1 :: Int -> String
test1 n = replace (show n) $ unlines [
  "id% : {A} → A → A",
  " = λ x. x",
  "",
  "id%Test : {A} → A → A",
  "  = id% id% id% id% id% id% id% id% id% id% id% id% id% id% id% id% id% id% id% id%",
  "    id% id% id% id% id% id% id% id% id% id% id% id% id% id% id% id% id% id% id% id%",
  "",
  "Nat% : U",
  " = (n : U) → (n → n) → n → n",
  "",
  "zero% : Nat%",
  " = λ n s z. z",
  "",
  "suc% : Nat% → Nat%",
  " = λ a n s z. s (a n s z)",
  "",
  "add% : Nat% → Nat% → Nat%",
  " = λ a b n s z. a n s (b n s z)",
  "",
  "mul% : Nat% → Nat% → Nat%",
  " = λ a b n s. a n (b n s)",
  "",
  "Eq% : {A} → A → A → U",
  " = λ {A} x y. (P : A → U) → P x → P y",
  "",
  "refl% : {A}{x : A} → Eq% x x",
  " = λ P px. px",
  "",
  "two%   : Nat% = λ N s z. s (s z)",
  "five%  : Nat% = λ N s z. s (s (s (s (s z))))",
  "n10%    = mul% two%  five%",
  "n10b%   = mul% five% two%",
  "n20%    = mul% two%  n10%",
  "n20b%   = mul% two%  n10b%",
  "n21%    = suc% n20%",
  "n21b%   = suc% n20b%",
  "n22%    = suc% n21%",
  "n22b%   = suc% n21b%",
  "n100%   = mul% n10%   n10%",
  "n100b%  = mul% n10b%  n10b%",
  "n10k%   = mul% n100%  n100%",
  "n10kb%  = mul% n100b% n100b%",
  "n100k%  = mul% n10k%  n10%",
  "n100kb% = mul% n10kb% n10b%",
  "n1M%    = mul% n10k%  n100%",
  "n1Mb%   = mul% n10kb% n100b%",
  "n5M%    = mul% n1M%   five%",
  "n5Mb%   = mul% n1Mb%  five%",
  "n10M%   = mul% n5M%   two%",
  "n10Mb%  = mul% n5Mb%  two%",
  "",
  "",
  "Vec% : U → Nat% → U",
  " = λ a n. (V : Nat% → U) → V zero% → ({n} → a → V n → V (suc% n)) → V n",
  "",
  "vnil% : {a} → Vec% a zero%",
  " = λ V n c. n",
  "",
  "vcons% : {a n} → a → Vec% a n → Vec% a (suc% n)",
  " = λ a as V n c. c a (as V n c)",
  "",
  "vec1% = (vcons% zero% (vcons% zero% (vcons% zero% (vcons% zero% (vcons% zero% (vcons% zero%",
  "       (vcons% zero% (vcons% zero% (vcons% zero% (vcons% zero% (vcons% zero% (vcons% zero%",
  "       (vcons% zero% (vcons% zero% (vcons% zero% (vcons% zero% (vcons% zero% (vcons% zero%",
  "       (vcons% zero% (vcons% zero% (vcons% zero% (vcons% zero% (vcons% zero% (vcons% zero%",
  "       (vcons% zero% (vcons% zero% (vcons% zero% (vcons% zero% (vcons% zero% (vcons% zero%",
  "       (vcons% zero% (vcons% zero% vnil%))))))))))))))))))))))))))))))))",
  "",
  "Pair% : U → U → U",
  " = λ A B. (Pair% : U)(pair : A → B → Pair%) → Pair%",
  "",
  "pair% : {A B} → A → B → Pair% A B",
  " = λ a b Pair% pair. pair a b",
  "",
  "proj1% : {A B} → Pair% A B → A",
  " = λ p. p _ (λ x y. x)",
  "",
  "proj2% : {A B} → Pair% A B → B",
  " = λ p. p _ (λ x y. y)",
  "",
  "Top% : U",
  " = (Top : U)(tt : Top) → Top",
  "",
  "tt% : Top%",
  " = λ Top tt. tt",
  "",
  "Bot% : U",
  " = (Bot : U) → Bot",
  "",
  "Ty% : U",
  " = (Ty  : U)",
  "   (ι   : Ty)",
  "   (fun : Ty → Ty → Ty)",
  " → Ty",
  "",
  "ι% : Ty%",
  " = λ _ ι _. ι",
  "",
  "fun% : Ty% → Ty% → Ty%",
  " = λ A B Ty ι fun. fun (A Ty ι fun) (B Ty ι fun)",
  "",
  "Con% : U",
  " = (Con : U)",
  "   (nil  : Con)",
  "   (cons : Con → Ty% → Con)",
  " → Con",
  "",
  "nil% : Con%",
  " = λ Con nil cons. nil",
  "",
  "cons% : Con% → Ty% → Con%",
  " = λ Γ A Con nil cons. cons (Γ Con nil cons) A",
  "",
  "Var% : Con% → Ty% → U",
  " = λ Γ A.",
  "   (Var : Con% → Ty% → U)",
  "   (vz  : {Γ A} → Var (cons% Γ A) A)",
  "   (vs  : {Γ B A} → Var Γ A → Var (cons% Γ B) A)",
  " → Var Γ A",
  "",
  "vz% : {Γ A} → Var% (cons% Γ A) A",
  " = λ Var vz vs. vz",
  "",
  "vs% : {Γ B A} → Var% Γ A → Var% (cons% Γ B) A",
  " = λ x Var vz vs. vs (x Var vz vs)",
  "",
  "Tm% : Con% → Ty% → U",
  " = λ Γ A.",
  "   (Tm  : Con% → Ty% → U)",
  "   (var : {Γ A} → Var% Γ A → Tm Γ A)",
  "   (lam : {Γ A B} → Tm (cons% Γ A) B → Tm Γ (fun% A B))",
  "   (app : {Γ A B} → Tm Γ (fun% A B) → Tm Γ A → Tm Γ B)",
  " → Tm Γ A",
  "",
  "var% : {Γ A} → Var% Γ A → Tm% Γ A",
  " = λ x Tm var lam app. var x",
  "",
  "lam% : {Γ A B} → Tm% (cons% Γ A) B → Tm% Γ (fun% A B)",
  " = λ t Tm var lam app. lam (t Tm var lam app)",
  "",
  "app% : {Γ A B} → Tm% Γ (fun% A B) → Tm% Γ A → Tm% Γ B",
  " = λ t u Tm var lam app. app (t Tm var lam app) (u Tm var lam app)",
  "",
  "EvalTy% : Ty% → U",
  " = λ A. A _ Bot% (λ A B. A → B)",
  "",
  "EvalCon% : Con% → U",
  " = λ Γ. Γ _ Top% (λ Δ A. Pair% Δ (EvalTy% A))",
  "",
  "EvalVar% : {Γ A} → Var% Γ A → EvalCon% Γ → EvalTy% A",
  " = λ x. x (λ Γ A. EvalCon% Γ → EvalTy% A)",
  "          (λ env. proj2% env)",
  "          (λ rec env. rec (proj1% env))",
  "",
  "EvalTm% : {Γ A} → Tm% Γ A → EvalCon% Γ → EvalTy% A",
  " = λ t. t _",
  "          EvalVar%",
  "          (λ t env α. t (pair% env α))",
  "          (λ t u env. t env (u env))",
  "",
  "test% : Tm% nil% (fun% (fun% ι% ι%) (fun% ι% ι%))",
  "  = lam% (lam% (app% (var% (vs% vz%)) (app% (var% (vs% vz%))",
  "             (app% (var% (vs% vz%)) (app% (var% (vs% vz%))",
  "             (app% (var% (vs% vz%)) (app% (var% (vs% vz%)) (var% vz%))))))))"

  ]
