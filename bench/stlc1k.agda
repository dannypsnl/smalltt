{-# OPTIONS --type-in-type #-}

Ty : Set
Ty =
   (Ty         : Set)
   (nat top bot  : Ty)
   (arr prod sum : Ty → Ty → Ty)
 → Ty

nat : Ty; nat = λ _ nat _ _ _ _ _ → nat
top : Ty; top = λ _ _ top _ _ _ _ → top
bot : Ty; bot = λ _ _ _ bot _ _ _ → bot

arr : Ty → Ty → Ty; arr
 = λ A B Ty nat top bot arr prod sum →
     arr (A Ty nat top bot arr prod sum) (B Ty nat top bot arr prod sum)

prod : Ty → Ty → Ty; prod
 = λ A B Ty nat top bot arr prod sum →
     prod (A Ty nat top bot arr prod sum) (B Ty nat top bot arr prod sum)

sum : Ty → Ty → Ty; sum
 = λ A B Ty nat top bot arr prod sum →
     sum (A Ty nat top bot arr prod sum) (B Ty nat top bot arr prod sum)

Con : Set; Con
 = (Con : Set)
   (nil  : Con)
   (snoc : Con → Ty → Con)
 → Con

nil : Con; nil
 = λ Con nil snoc → nil

snoc : Con → Ty → Con; snoc
 = λ Γ A Con nil snoc → snoc (Γ Con nil snoc) A

Var : Con → Ty → Set; Var
 = λ Γ A →
   (Var : Con → Ty → Set)
   (vz  : ∀{Γ A} → Var (snoc Γ A) A)
   (vs  : ∀{Γ B A} → Var Γ A → Var (snoc Γ B) A)
 → Var Γ A

vz : ∀{Γ A} → Var (snoc Γ A) A; vz
 = λ Var vz vs → vz

vs : ∀{Γ B A} → Var Γ A → Var (snoc Γ B) A; vs
 = λ x Var vz vs → vs (x Var vz vs)

Tm : Con → Ty → Set; Tm
 = λ Γ A →
   (Tm  : Con → Ty → Set)
   (var   : ∀{Γ A} → Var Γ A → Tm Γ A)
   (lam   : ∀{Γ A B} → Tm (snoc Γ A) B → Tm Γ (arr A B))
   (app   : ∀{Γ A B} → Tm Γ (arr A B) → Tm Γ A → Tm Γ B)
   (tt    : ∀{Γ} → Tm Γ top)
   (pair  : ∀{Γ A B} → Tm Γ A → Tm Γ B → Tm Γ (prod A B))
   (fst   : ∀{Γ A B} → Tm Γ (prod A B) → Tm Γ A)
   (snd   : ∀{Γ A B} → Tm Γ (prod A B) → Tm Γ B)
   (left  : ∀{Γ A B} → Tm Γ A → Tm Γ (sum A B))
   (right : ∀{Γ A B} → Tm Γ B → Tm Γ (sum A B))
   (case  : ∀{Γ A B C} → Tm Γ (sum A B) → Tm Γ (arr A C) → Tm Γ (arr B C) → Tm Γ C)
   (zero  : ∀{Γ} → Tm Γ nat)
   (suc   : ∀{Γ} → Tm Γ nat → Tm Γ nat)
   (rec   : ∀{Γ A} → Tm Γ nat → Tm Γ (arr nat (arr A A)) → Tm Γ A → Tm Γ A)
 → Tm Γ A

var : ∀{Γ A} → Var Γ A → Tm Γ A; var
 = λ x Tm var lam app tt pair fst snd left right case zero suc rec →
     var x

lam : ∀{Γ A B} → Tm (snoc Γ A) B → Tm Γ (arr A B); lam
 = λ t Tm var lam app tt pair fst snd left right case zero suc rec →
     lam (t Tm var lam app tt pair fst snd left right case zero suc rec)

app : ∀{Γ A B} → Tm Γ (arr A B) → Tm Γ A → Tm Γ B; app
 = λ t u Tm var lam app tt pair fst snd left right case zero suc rec →
     app (t Tm var lam app tt pair fst snd left right case zero suc rec)
         (u Tm var lam app tt pair fst snd left right case zero suc rec)

tt : ∀{Γ} → Tm Γ top; tt
 = λ Tm var lam app tt pair fst snd left right case zero suc rec → tt

pair : ∀{Γ A B} → Tm Γ A → Tm Γ B → Tm Γ (prod A B); pair
 = λ t u Tm var lam app tt pair fst snd left right case zero suc rec →
     pair (t Tm var lam app tt pair fst snd left right case zero suc rec)
          (u Tm var lam app tt pair fst snd left right case zero suc rec)

fst : ∀{Γ A B} → Tm Γ (prod A B) → Tm Γ A; fst
 = λ t Tm var lam app tt pair fst snd left right case zero suc rec →
     fst (t Tm var lam app tt pair fst snd left right case zero suc rec)

snd : ∀{Γ A B} → Tm Γ (prod A B) → Tm Γ B; snd
 = λ t Tm var lam app tt pair fst snd left right case zero suc rec →
     snd (t Tm var lam app tt pair fst snd left right case zero suc rec)

left : ∀{Γ A B} → Tm Γ A → Tm Γ (sum A B); left
 = λ t Tm var lam app tt pair fst snd left right case zero suc rec →
     left (t Tm var lam app tt pair fst snd left right case zero suc rec)

right : ∀{Γ A B} → Tm Γ B → Tm Γ (sum A B); right
 = λ t Tm var lam app tt pair fst snd left right case zero suc rec →
     right (t Tm var lam app tt pair fst snd left right case zero suc rec)

case : ∀{Γ A B C} → Tm Γ (sum A B) → Tm Γ (arr A C) → Tm Γ (arr B C) → Tm Γ C; case
 = λ t u v Tm var lam app tt pair fst snd left right case zero suc rec →
     case (t Tm var lam app tt pair fst snd left right case zero suc rec)
           (u Tm var lam app tt pair fst snd left right case zero suc rec)
           (v Tm var lam app tt pair fst snd left right case zero suc rec)

zero  : ∀{Γ} → Tm Γ nat; zero
 = λ Tm var lam app tt pair fst snd left right case zero suc rec → zero

suc : ∀{Γ} → Tm Γ nat → Tm Γ nat; suc
 = λ t Tm var lam app tt pair fst snd left right case zero suc rec →
   suc (t Tm var lam app tt pair fst snd left right case zero suc rec)

rec : ∀{Γ A} → Tm Γ nat → Tm Γ (arr nat (arr A A)) → Tm Γ A → Tm Γ A; rec
 = λ t u v Tm var lam app tt pair fst snd left right case zero suc rec →
     rec (t Tm var lam app tt pair fst snd left right case zero suc rec)
         (u Tm var lam app tt pair fst snd left right case zero suc rec)
         (v Tm var lam app tt pair fst snd left right case zero suc rec)

v0 : ∀{Γ A} → Tm (snoc Γ A) A; v0
 = var vz

v1 : ∀{Γ A B} → Tm (snoc (snoc Γ A) B) A; v1
 = var (vs vz)

v2 : ∀{Γ A B C} → Tm (snoc (snoc (snoc Γ A) B) C) A; v2
 = var (vs (vs vz))

v3 : ∀{Γ A B C D} → Tm (snoc (snoc (snoc (snoc Γ A) B) C) D) A; v3
 = var (vs (vs (vs vz)))

tbool : Ty; tbool
 = sum top top

true : ∀{Γ} → Tm Γ tbool; true
 = left tt

tfalse : ∀{Γ} → Tm Γ tbool; tfalse
 = right tt

ifthenelse : ∀{Γ A} → Tm Γ (arr tbool (arr A (arr A A))); ifthenelse
 = lam (lam (lam (case v2 (lam v2) (lam v1))))

times4 : ∀{Γ A} → Tm Γ (arr (arr A A) (arr A A)); times4
  = lam (lam (app v1 (app v1 (app v1 (app v1 v0)))))

add : ∀{Γ} → Tm Γ (arr nat (arr nat nat)); add
 = lam (rec v0
       (lam (lam (lam (suc (app v1 v0)))))
       (lam v0))

mul : ∀{Γ} → Tm Γ (arr nat (arr nat nat)); mul
 = lam (rec v0
       (lam (lam (lam (app (app add (app v1 v0)) v0))))
       (lam zero))

fact : ∀{Γ} → Tm Γ (arr nat nat); fact
 = lam (rec v0 (lam (lam (app (app mul (suc v1)) v0)))
        (suc zero))
{-# OPTIONS --type-in-type #-}

Ty1 : Set
Ty1 =
   (Ty1         : Set)
   (nat top bot  : Ty1)
   (arr prod sum : Ty1 → Ty1 → Ty1)
 → Ty1

nat1 : Ty1; nat1 = λ _ nat1 _ _ _ _ _ → nat1
top1 : Ty1; top1 = λ _ _ top1 _ _ _ _ → top1
bot1 : Ty1; bot1 = λ _ _ _ bot1 _ _ _ → bot1

arr1 : Ty1 → Ty1 → Ty1; arr1
 = λ A B Ty1 nat1 top1 bot1 arr1 prod sum →
     arr1 (A Ty1 nat1 top1 bot1 arr1 prod sum) (B Ty1 nat1 top1 bot1 arr1 prod sum)

prod1 : Ty1 → Ty1 → Ty1; prod1
 = λ A B Ty1 nat1 top1 bot1 arr1 prod1 sum →
     prod1 (A Ty1 nat1 top1 bot1 arr1 prod1 sum) (B Ty1 nat1 top1 bot1 arr1 prod1 sum)

sum1 : Ty1 → Ty1 → Ty1; sum1
 = λ A B Ty1 nat1 top1 bot1 arr1 prod1 sum1 →
     sum1 (A Ty1 nat1 top1 bot1 arr1 prod1 sum1) (B Ty1 nat1 top1 bot1 arr1 prod1 sum1)

Con1 : Set; Con1
 = (Con1 : Set)
   (nil  : Con1)
   (snoc : Con1 → Ty1 → Con1)
 → Con1

nil1 : Con1; nil1
 = λ Con1 nil1 snoc → nil1

snoc1 : Con1 → Ty1 → Con1; snoc1
 = λ Γ A Con1 nil1 snoc1 → snoc1 (Γ Con1 nil1 snoc1) A

Var1 : Con1 → Ty1 → Set; Var1
 = λ Γ A →
   (Var1 : Con1 → Ty1 → Set)
   (vz  : ∀{Γ A} → Var1 (snoc1 Γ A) A)
   (vs  : ∀{Γ B A} → Var1 Γ A → Var1 (snoc1 Γ B) A)
 → Var1 Γ A

vz1 : ∀{Γ A} → Var1 (snoc1 Γ A) A; vz1
 = λ Var1 vz1 vs → vz1

vs1 : ∀{Γ B A} → Var1 Γ A → Var1 (snoc1 Γ B) A; vs1
 = λ x Var1 vz1 vs1 → vs1 (x Var1 vz1 vs1)

Tm1 : Con1 → Ty1 → Set; Tm1
 = λ Γ A →
   (Tm1  : Con1 → Ty1 → Set)
   (var   : ∀{Γ A} → Var1 Γ A → Tm1 Γ A)
   (lam   : ∀{Γ A B} → Tm1 (snoc1 Γ A) B → Tm1 Γ (arr1 A B))
   (app   : ∀{Γ A B} → Tm1 Γ (arr1 A B) → Tm1 Γ A → Tm1 Γ B)
   (tt    : ∀{Γ} → Tm1 Γ top1)
   (pair  : ∀{Γ A B} → Tm1 Γ A → Tm1 Γ B → Tm1 Γ (prod1 A B))
   (fst   : ∀{Γ A B} → Tm1 Γ (prod1 A B) → Tm1 Γ A)
   (snd   : ∀{Γ A B} → Tm1 Γ (prod1 A B) → Tm1 Γ B)
   (left  : ∀{Γ A B} → Tm1 Γ A → Tm1 Γ (sum1 A B))
   (right : ∀{Γ A B} → Tm1 Γ B → Tm1 Γ (sum1 A B))
   (case  : ∀{Γ A B C} → Tm1 Γ (sum1 A B) → Tm1 Γ (arr1 A C) → Tm1 Γ (arr1 B C) → Tm1 Γ C)
   (zero  : ∀{Γ} → Tm1 Γ nat1)
   (suc   : ∀{Γ} → Tm1 Γ nat1 → Tm1 Γ nat1)
   (rec   : ∀{Γ A} → Tm1 Γ nat1 → Tm1 Γ (arr1 nat1 (arr1 A A)) → Tm1 Γ A → Tm1 Γ A)
 → Tm1 Γ A

var1 : ∀{Γ A} → Var1 Γ A → Tm1 Γ A; var1
 = λ x Tm1 var1 lam app tt pair fst snd left right case zero suc rec →
     var1 x

lam1 : ∀{Γ A B} → Tm1 (snoc1 Γ A) B → Tm1 Γ (arr1 A B); lam1
 = λ t Tm1 var1 lam1 app tt pair fst snd left right case zero suc rec →
     lam1 (t Tm1 var1 lam1 app tt pair fst snd left right case zero suc rec)

app1 : ∀{Γ A B} → Tm1 Γ (arr1 A B) → Tm1 Γ A → Tm1 Γ B; app1
 = λ t u Tm1 var1 lam1 app1 tt pair fst snd left right case zero suc rec →
     app1 (t Tm1 var1 lam1 app1 tt pair fst snd left right case zero suc rec)
         (u Tm1 var1 lam1 app1 tt pair fst snd left right case zero suc rec)

tt1 : ∀{Γ} → Tm1 Γ top1; tt1
 = λ Tm1 var1 lam1 app1 tt1 pair fst snd left right case zero suc rec → tt1

pair1 : ∀{Γ A B} → Tm1 Γ A → Tm1 Γ B → Tm1 Γ (prod1 A B); pair1
 = λ t u Tm1 var1 lam1 app1 tt1 pair1 fst snd left right case zero suc rec →
     pair1 (t Tm1 var1 lam1 app1 tt1 pair1 fst snd left right case zero suc rec)
          (u Tm1 var1 lam1 app1 tt1 pair1 fst snd left right case zero suc rec)

fst1 : ∀{Γ A B} → Tm1 Γ (prod1 A B) → Tm1 Γ A; fst1
 = λ t Tm1 var1 lam1 app1 tt1 pair1 fst1 snd left right case zero suc rec →
     fst1 (t Tm1 var1 lam1 app1 tt1 pair1 fst1 snd left right case zero suc rec)

snd1 : ∀{Γ A B} → Tm1 Γ (prod1 A B) → Tm1 Γ B; snd1
 = λ t Tm1 var1 lam1 app1 tt1 pair1 fst1 snd1 left right case zero suc rec →
     snd1 (t Tm1 var1 lam1 app1 tt1 pair1 fst1 snd1 left right case zero suc rec)

left1 : ∀{Γ A B} → Tm1 Γ A → Tm1 Γ (sum1 A B); left1
 = λ t Tm1 var1 lam1 app1 tt1 pair1 fst1 snd1 left1 right case zero suc rec →
     left1 (t Tm1 var1 lam1 app1 tt1 pair1 fst1 snd1 left1 right case zero suc rec)

right1 : ∀{Γ A B} → Tm1 Γ B → Tm1 Γ (sum1 A B); right1
 = λ t Tm1 var1 lam1 app1 tt1 pair1 fst1 snd1 left1 right1 case zero suc rec →
     right1 (t Tm1 var1 lam1 app1 tt1 pair1 fst1 snd1 left1 right1 case zero suc rec)

case1 : ∀{Γ A B C} → Tm1 Γ (sum1 A B) → Tm1 Γ (arr1 A C) → Tm1 Γ (arr1 B C) → Tm1 Γ C; case1
 = λ t u v Tm1 var1 lam1 app1 tt1 pair1 fst1 snd1 left1 right1 case1 zero suc rec →
     case1 (t Tm1 var1 lam1 app1 tt1 pair1 fst1 snd1 left1 right1 case1 zero suc rec)
           (u Tm1 var1 lam1 app1 tt1 pair1 fst1 snd1 left1 right1 case1 zero suc rec)
           (v Tm1 var1 lam1 app1 tt1 pair1 fst1 snd1 left1 right1 case1 zero suc rec)

zero1  : ∀{Γ} → Tm1 Γ nat1; zero1
 = λ Tm1 var1 lam1 app1 tt1 pair1 fst1 snd1 left1 right1 case1 zero1 suc rec → zero1

suc1 : ∀{Γ} → Tm1 Γ nat1 → Tm1 Γ nat1; suc1
 = λ t Tm1 var1 lam1 app1 tt1 pair1 fst1 snd1 left1 right1 case1 zero1 suc1 rec →
   suc1 (t Tm1 var1 lam1 app1 tt1 pair1 fst1 snd1 left1 right1 case1 zero1 suc1 rec)

rec1 : ∀{Γ A} → Tm1 Γ nat1 → Tm1 Γ (arr1 nat1 (arr1 A A)) → Tm1 Γ A → Tm1 Γ A; rec1
 = λ t u v Tm1 var1 lam1 app1 tt1 pair1 fst1 snd1 left1 right1 case1 zero1 suc1 rec1 →
     rec1 (t Tm1 var1 lam1 app1 tt1 pair1 fst1 snd1 left1 right1 case1 zero1 suc1 rec1)
         (u Tm1 var1 lam1 app1 tt1 pair1 fst1 snd1 left1 right1 case1 zero1 suc1 rec1)
         (v Tm1 var1 lam1 app1 tt1 pair1 fst1 snd1 left1 right1 case1 zero1 suc1 rec1)

v01 : ∀{Γ A} → Tm1 (snoc1 Γ A) A; v01
 = var1 vz1

v11 : ∀{Γ A B} → Tm1 (snoc1 (snoc1 Γ A) B) A; v11
 = var1 (vs1 vz1)

v21 : ∀{Γ A B C} → Tm1 (snoc1 (snoc1 (snoc1 Γ A) B) C) A; v21
 = var1 (vs1 (vs1 vz1))

v31 : ∀{Γ A B C D} → Tm1 (snoc1 (snoc1 (snoc1 (snoc1 Γ A) B) C) D) A; v31
 = var1 (vs1 (vs1 (vs1 vz1)))

tbool1 : Ty1; tbool1
 = sum1 top1 top1

true1 : ∀{Γ} → Tm1 Γ tbool1; true1
 = left1 tt1

tfalse1 : ∀{Γ} → Tm1 Γ tbool1; tfalse1
 = right1 tt1

ifthenelse1 : ∀{Γ A} → Tm1 Γ (arr1 tbool1 (arr1 A (arr1 A A))); ifthenelse1
 = lam1 (lam1 (lam1 (case1 v21 (lam1 v21) (lam1 v11))))

times41 : ∀{Γ A} → Tm1 Γ (arr1 (arr1 A A) (arr1 A A)); times41
  = lam1 (lam1 (app1 v11 (app1 v11 (app1 v11 (app1 v11 v01)))))

add1 : ∀{Γ} → Tm1 Γ (arr1 nat1 (arr1 nat1 nat1)); add1
 = lam1 (rec1 v01
       (lam1 (lam1 (lam1 (suc1 (app1 v11 v01)))))
       (lam1 v01))

mul1 : ∀{Γ} → Tm1 Γ (arr1 nat1 (arr1 nat1 nat1)); mul1
 = lam1 (rec1 v01
       (lam1 (lam1 (lam1 (app1 (app1 add1 (app1 v11 v01)) v01))))
       (lam1 zero1))

fact1 : ∀{Γ} → Tm1 Γ (arr1 nat1 nat1); fact1
 = lam1 (rec1 v01 (lam1 (lam1 (app1 (app1 mul1 (suc1 v11)) v01)))
        (suc1 zero1))
{-# OPTIONS --type-in-type #-}

Ty2 : Set
Ty2 =
   (Ty2         : Set)
   (nat top bot  : Ty2)
   (arr prod sum : Ty2 → Ty2 → Ty2)
 → Ty2

nat2 : Ty2; nat2 = λ _ nat2 _ _ _ _ _ → nat2
top2 : Ty2; top2 = λ _ _ top2 _ _ _ _ → top2
bot2 : Ty2; bot2 = λ _ _ _ bot2 _ _ _ → bot2

arr2 : Ty2 → Ty2 → Ty2; arr2
 = λ A B Ty2 nat2 top2 bot2 arr2 prod sum →
     arr2 (A Ty2 nat2 top2 bot2 arr2 prod sum) (B Ty2 nat2 top2 bot2 arr2 prod sum)

prod2 : Ty2 → Ty2 → Ty2; prod2
 = λ A B Ty2 nat2 top2 bot2 arr2 prod2 sum →
     prod2 (A Ty2 nat2 top2 bot2 arr2 prod2 sum) (B Ty2 nat2 top2 bot2 arr2 prod2 sum)

sum2 : Ty2 → Ty2 → Ty2; sum2
 = λ A B Ty2 nat2 top2 bot2 arr2 prod2 sum2 →
     sum2 (A Ty2 nat2 top2 bot2 arr2 prod2 sum2) (B Ty2 nat2 top2 bot2 arr2 prod2 sum2)

Con2 : Set; Con2
 = (Con2 : Set)
   (nil  : Con2)
   (snoc : Con2 → Ty2 → Con2)
 → Con2

nil2 : Con2; nil2
 = λ Con2 nil2 snoc → nil2

snoc2 : Con2 → Ty2 → Con2; snoc2
 = λ Γ A Con2 nil2 snoc2 → snoc2 (Γ Con2 nil2 snoc2) A

Var2 : Con2 → Ty2 → Set; Var2
 = λ Γ A →
   (Var2 : Con2 → Ty2 → Set)
   (vz  : ∀{Γ A} → Var2 (snoc2 Γ A) A)
   (vs  : ∀{Γ B A} → Var2 Γ A → Var2 (snoc2 Γ B) A)
 → Var2 Γ A

vz2 : ∀{Γ A} → Var2 (snoc2 Γ A) A; vz2
 = λ Var2 vz2 vs → vz2

vs2 : ∀{Γ B A} → Var2 Γ A → Var2 (snoc2 Γ B) A; vs2
 = λ x Var2 vz2 vs2 → vs2 (x Var2 vz2 vs2)

Tm2 : Con2 → Ty2 → Set; Tm2
 = λ Γ A →
   (Tm2  : Con2 → Ty2 → Set)
   (var   : ∀{Γ A} → Var2 Γ A → Tm2 Γ A)
   (lam   : ∀{Γ A B} → Tm2 (snoc2 Γ A) B → Tm2 Γ (arr2 A B))
   (app   : ∀{Γ A B} → Tm2 Γ (arr2 A B) → Tm2 Γ A → Tm2 Γ B)
   (tt    : ∀{Γ} → Tm2 Γ top2)
   (pair  : ∀{Γ A B} → Tm2 Γ A → Tm2 Γ B → Tm2 Γ (prod2 A B))
   (fst   : ∀{Γ A B} → Tm2 Γ (prod2 A B) → Tm2 Γ A)
   (snd   : ∀{Γ A B} → Tm2 Γ (prod2 A B) → Tm2 Γ B)
   (left  : ∀{Γ A B} → Tm2 Γ A → Tm2 Γ (sum2 A B))
   (right : ∀{Γ A B} → Tm2 Γ B → Tm2 Γ (sum2 A B))
   (case  : ∀{Γ A B C} → Tm2 Γ (sum2 A B) → Tm2 Γ (arr2 A C) → Tm2 Γ (arr2 B C) → Tm2 Γ C)
   (zero  : ∀{Γ} → Tm2 Γ nat2)
   (suc   : ∀{Γ} → Tm2 Γ nat2 → Tm2 Γ nat2)
   (rec   : ∀{Γ A} → Tm2 Γ nat2 → Tm2 Γ (arr2 nat2 (arr2 A A)) → Tm2 Γ A → Tm2 Γ A)
 → Tm2 Γ A

var2 : ∀{Γ A} → Var2 Γ A → Tm2 Γ A; var2
 = λ x Tm2 var2 lam app tt pair fst snd left right case zero suc rec →
     var2 x

lam2 : ∀{Γ A B} → Tm2 (snoc2 Γ A) B → Tm2 Γ (arr2 A B); lam2
 = λ t Tm2 var2 lam2 app tt pair fst snd left right case zero suc rec →
     lam2 (t Tm2 var2 lam2 app tt pair fst snd left right case zero suc rec)

app2 : ∀{Γ A B} → Tm2 Γ (arr2 A B) → Tm2 Γ A → Tm2 Γ B; app2
 = λ t u Tm2 var2 lam2 app2 tt pair fst snd left right case zero suc rec →
     app2 (t Tm2 var2 lam2 app2 tt pair fst snd left right case zero suc rec)
         (u Tm2 var2 lam2 app2 tt pair fst snd left right case zero suc rec)

tt2 : ∀{Γ} → Tm2 Γ top2; tt2
 = λ Tm2 var2 lam2 app2 tt2 pair fst snd left right case zero suc rec → tt2

pair2 : ∀{Γ A B} → Tm2 Γ A → Tm2 Γ B → Tm2 Γ (prod2 A B); pair2
 = λ t u Tm2 var2 lam2 app2 tt2 pair2 fst snd left right case zero suc rec →
     pair2 (t Tm2 var2 lam2 app2 tt2 pair2 fst snd left right case zero suc rec)
          (u Tm2 var2 lam2 app2 tt2 pair2 fst snd left right case zero suc rec)

fst2 : ∀{Γ A B} → Tm2 Γ (prod2 A B) → Tm2 Γ A; fst2
 = λ t Tm2 var2 lam2 app2 tt2 pair2 fst2 snd left right case zero suc rec →
     fst2 (t Tm2 var2 lam2 app2 tt2 pair2 fst2 snd left right case zero suc rec)

snd2 : ∀{Γ A B} → Tm2 Γ (prod2 A B) → Tm2 Γ B; snd2
 = λ t Tm2 var2 lam2 app2 tt2 pair2 fst2 snd2 left right case zero suc rec →
     snd2 (t Tm2 var2 lam2 app2 tt2 pair2 fst2 snd2 left right case zero suc rec)

left2 : ∀{Γ A B} → Tm2 Γ A → Tm2 Γ (sum2 A B); left2
 = λ t Tm2 var2 lam2 app2 tt2 pair2 fst2 snd2 left2 right case zero suc rec →
     left2 (t Tm2 var2 lam2 app2 tt2 pair2 fst2 snd2 left2 right case zero suc rec)

right2 : ∀{Γ A B} → Tm2 Γ B → Tm2 Γ (sum2 A B); right2
 = λ t Tm2 var2 lam2 app2 tt2 pair2 fst2 snd2 left2 right2 case zero suc rec →
     right2 (t Tm2 var2 lam2 app2 tt2 pair2 fst2 snd2 left2 right2 case zero suc rec)

case2 : ∀{Γ A B C} → Tm2 Γ (sum2 A B) → Tm2 Γ (arr2 A C) → Tm2 Γ (arr2 B C) → Tm2 Γ C; case2
 = λ t u v Tm2 var2 lam2 app2 tt2 pair2 fst2 snd2 left2 right2 case2 zero suc rec →
     case2 (t Tm2 var2 lam2 app2 tt2 pair2 fst2 snd2 left2 right2 case2 zero suc rec)
           (u Tm2 var2 lam2 app2 tt2 pair2 fst2 snd2 left2 right2 case2 zero suc rec)
           (v Tm2 var2 lam2 app2 tt2 pair2 fst2 snd2 left2 right2 case2 zero suc rec)

zero2  : ∀{Γ} → Tm2 Γ nat2; zero2
 = λ Tm2 var2 lam2 app2 tt2 pair2 fst2 snd2 left2 right2 case2 zero2 suc rec → zero2

suc2 : ∀{Γ} → Tm2 Γ nat2 → Tm2 Γ nat2; suc2
 = λ t Tm2 var2 lam2 app2 tt2 pair2 fst2 snd2 left2 right2 case2 zero2 suc2 rec →
   suc2 (t Tm2 var2 lam2 app2 tt2 pair2 fst2 snd2 left2 right2 case2 zero2 suc2 rec)

rec2 : ∀{Γ A} → Tm2 Γ nat2 → Tm2 Γ (arr2 nat2 (arr2 A A)) → Tm2 Γ A → Tm2 Γ A; rec2
 = λ t u v Tm2 var2 lam2 app2 tt2 pair2 fst2 snd2 left2 right2 case2 zero2 suc2 rec2 →
     rec2 (t Tm2 var2 lam2 app2 tt2 pair2 fst2 snd2 left2 right2 case2 zero2 suc2 rec2)
         (u Tm2 var2 lam2 app2 tt2 pair2 fst2 snd2 left2 right2 case2 zero2 suc2 rec2)
         (v Tm2 var2 lam2 app2 tt2 pair2 fst2 snd2 left2 right2 case2 zero2 suc2 rec2)

v02 : ∀{Γ A} → Tm2 (snoc2 Γ A) A; v02
 = var2 vz2

v12 : ∀{Γ A B} → Tm2 (snoc2 (snoc2 Γ A) B) A; v12
 = var2 (vs2 vz2)

v22 : ∀{Γ A B C} → Tm2 (snoc2 (snoc2 (snoc2 Γ A) B) C) A; v22
 = var2 (vs2 (vs2 vz2))

v32 : ∀{Γ A B C D} → Tm2 (snoc2 (snoc2 (snoc2 (snoc2 Γ A) B) C) D) A; v32
 = var2 (vs2 (vs2 (vs2 vz2)))

tbool2 : Ty2; tbool2
 = sum2 top2 top2

true2 : ∀{Γ} → Tm2 Γ tbool2; true2
 = left2 tt2

tfalse2 : ∀{Γ} → Tm2 Γ tbool2; tfalse2
 = right2 tt2

ifthenelse2 : ∀{Γ A} → Tm2 Γ (arr2 tbool2 (arr2 A (arr2 A A))); ifthenelse2
 = lam2 (lam2 (lam2 (case2 v22 (lam2 v22) (lam2 v12))))

times42 : ∀{Γ A} → Tm2 Γ (arr2 (arr2 A A) (arr2 A A)); times42
  = lam2 (lam2 (app2 v12 (app2 v12 (app2 v12 (app2 v12 v02)))))

add2 : ∀{Γ} → Tm2 Γ (arr2 nat2 (arr2 nat2 nat2)); add2
 = lam2 (rec2 v02
       (lam2 (lam2 (lam2 (suc2 (app2 v12 v02)))))
       (lam2 v02))

mul2 : ∀{Γ} → Tm2 Γ (arr2 nat2 (arr2 nat2 nat2)); mul2
 = lam2 (rec2 v02
       (lam2 (lam2 (lam2 (app2 (app2 add2 (app2 v12 v02)) v02))))
       (lam2 zero2))

fact2 : ∀{Γ} → Tm2 Γ (arr2 nat2 nat2); fact2
 = lam2 (rec2 v02 (lam2 (lam2 (app2 (app2 mul2 (suc2 v12)) v02)))
        (suc2 zero2))
{-# OPTIONS --type-in-type #-}

Ty3 : Set
Ty3 =
   (Ty3         : Set)
   (nat top bot  : Ty3)
   (arr prod sum : Ty3 → Ty3 → Ty3)
 → Ty3

nat3 : Ty3; nat3 = λ _ nat3 _ _ _ _ _ → nat3
top3 : Ty3; top3 = λ _ _ top3 _ _ _ _ → top3
bot3 : Ty3; bot3 = λ _ _ _ bot3 _ _ _ → bot3

arr3 : Ty3 → Ty3 → Ty3; arr3
 = λ A B Ty3 nat3 top3 bot3 arr3 prod sum →
     arr3 (A Ty3 nat3 top3 bot3 arr3 prod sum) (B Ty3 nat3 top3 bot3 arr3 prod sum)

prod3 : Ty3 → Ty3 → Ty3; prod3
 = λ A B Ty3 nat3 top3 bot3 arr3 prod3 sum →
     prod3 (A Ty3 nat3 top3 bot3 arr3 prod3 sum) (B Ty3 nat3 top3 bot3 arr3 prod3 sum)

sum3 : Ty3 → Ty3 → Ty3; sum3
 = λ A B Ty3 nat3 top3 bot3 arr3 prod3 sum3 →
     sum3 (A Ty3 nat3 top3 bot3 arr3 prod3 sum3) (B Ty3 nat3 top3 bot3 arr3 prod3 sum3)

Con3 : Set; Con3
 = (Con3 : Set)
   (nil  : Con3)
   (snoc : Con3 → Ty3 → Con3)
 → Con3

nil3 : Con3; nil3
 = λ Con3 nil3 snoc → nil3

snoc3 : Con3 → Ty3 → Con3; snoc3
 = λ Γ A Con3 nil3 snoc3 → snoc3 (Γ Con3 nil3 snoc3) A

Var3 : Con3 → Ty3 → Set; Var3
 = λ Γ A →
   (Var3 : Con3 → Ty3 → Set)
   (vz  : ∀{Γ A} → Var3 (snoc3 Γ A) A)
   (vs  : ∀{Γ B A} → Var3 Γ A → Var3 (snoc3 Γ B) A)
 → Var3 Γ A

vz3 : ∀{Γ A} → Var3 (snoc3 Γ A) A; vz3
 = λ Var3 vz3 vs → vz3

vs3 : ∀{Γ B A} → Var3 Γ A → Var3 (snoc3 Γ B) A; vs3
 = λ x Var3 vz3 vs3 → vs3 (x Var3 vz3 vs3)

Tm3 : Con3 → Ty3 → Set; Tm3
 = λ Γ A →
   (Tm3  : Con3 → Ty3 → Set)
   (var   : ∀{Γ A} → Var3 Γ A → Tm3 Γ A)
   (lam   : ∀{Γ A B} → Tm3 (snoc3 Γ A) B → Tm3 Γ (arr3 A B))
   (app   : ∀{Γ A B} → Tm3 Γ (arr3 A B) → Tm3 Γ A → Tm3 Γ B)
   (tt    : ∀{Γ} → Tm3 Γ top3)
   (pair  : ∀{Γ A B} → Tm3 Γ A → Tm3 Γ B → Tm3 Γ (prod3 A B))
   (fst   : ∀{Γ A B} → Tm3 Γ (prod3 A B) → Tm3 Γ A)
   (snd   : ∀{Γ A B} → Tm3 Γ (prod3 A B) → Tm3 Γ B)
   (left  : ∀{Γ A B} → Tm3 Γ A → Tm3 Γ (sum3 A B))
   (right : ∀{Γ A B} → Tm3 Γ B → Tm3 Γ (sum3 A B))
   (case  : ∀{Γ A B C} → Tm3 Γ (sum3 A B) → Tm3 Γ (arr3 A C) → Tm3 Γ (arr3 B C) → Tm3 Γ C)
   (zero  : ∀{Γ} → Tm3 Γ nat3)
   (suc   : ∀{Γ} → Tm3 Γ nat3 → Tm3 Γ nat3)
   (rec   : ∀{Γ A} → Tm3 Γ nat3 → Tm3 Γ (arr3 nat3 (arr3 A A)) → Tm3 Γ A → Tm3 Γ A)
 → Tm3 Γ A

var3 : ∀{Γ A} → Var3 Γ A → Tm3 Γ A; var3
 = λ x Tm3 var3 lam app tt pair fst snd left right case zero suc rec →
     var3 x

lam3 : ∀{Γ A B} → Tm3 (snoc3 Γ A) B → Tm3 Γ (arr3 A B); lam3
 = λ t Tm3 var3 lam3 app tt pair fst snd left right case zero suc rec →
     lam3 (t Tm3 var3 lam3 app tt pair fst snd left right case zero suc rec)

app3 : ∀{Γ A B} → Tm3 Γ (arr3 A B) → Tm3 Γ A → Tm3 Γ B; app3
 = λ t u Tm3 var3 lam3 app3 tt pair fst snd left right case zero suc rec →
     app3 (t Tm3 var3 lam3 app3 tt pair fst snd left right case zero suc rec)
         (u Tm3 var3 lam3 app3 tt pair fst snd left right case zero suc rec)

tt3 : ∀{Γ} → Tm3 Γ top3; tt3
 = λ Tm3 var3 lam3 app3 tt3 pair fst snd left right case zero suc rec → tt3

pair3 : ∀{Γ A B} → Tm3 Γ A → Tm3 Γ B → Tm3 Γ (prod3 A B); pair3
 = λ t u Tm3 var3 lam3 app3 tt3 pair3 fst snd left right case zero suc rec →
     pair3 (t Tm3 var3 lam3 app3 tt3 pair3 fst snd left right case zero suc rec)
          (u Tm3 var3 lam3 app3 tt3 pair3 fst snd left right case zero suc rec)

fst3 : ∀{Γ A B} → Tm3 Γ (prod3 A B) → Tm3 Γ A; fst3
 = λ t Tm3 var3 lam3 app3 tt3 pair3 fst3 snd left right case zero suc rec →
     fst3 (t Tm3 var3 lam3 app3 tt3 pair3 fst3 snd left right case zero suc rec)

snd3 : ∀{Γ A B} → Tm3 Γ (prod3 A B) → Tm3 Γ B; snd3
 = λ t Tm3 var3 lam3 app3 tt3 pair3 fst3 snd3 left right case zero suc rec →
     snd3 (t Tm3 var3 lam3 app3 tt3 pair3 fst3 snd3 left right case zero suc rec)

left3 : ∀{Γ A B} → Tm3 Γ A → Tm3 Γ (sum3 A B); left3
 = λ t Tm3 var3 lam3 app3 tt3 pair3 fst3 snd3 left3 right case zero suc rec →
     left3 (t Tm3 var3 lam3 app3 tt3 pair3 fst3 snd3 left3 right case zero suc rec)

right3 : ∀{Γ A B} → Tm3 Γ B → Tm3 Γ (sum3 A B); right3
 = λ t Tm3 var3 lam3 app3 tt3 pair3 fst3 snd3 left3 right3 case zero suc rec →
     right3 (t Tm3 var3 lam3 app3 tt3 pair3 fst3 snd3 left3 right3 case zero suc rec)

case3 : ∀{Γ A B C} → Tm3 Γ (sum3 A B) → Tm3 Γ (arr3 A C) → Tm3 Γ (arr3 B C) → Tm3 Γ C; case3
 = λ t u v Tm3 var3 lam3 app3 tt3 pair3 fst3 snd3 left3 right3 case3 zero suc rec →
     case3 (t Tm3 var3 lam3 app3 tt3 pair3 fst3 snd3 left3 right3 case3 zero suc rec)
           (u Tm3 var3 lam3 app3 tt3 pair3 fst3 snd3 left3 right3 case3 zero suc rec)
           (v Tm3 var3 lam3 app3 tt3 pair3 fst3 snd3 left3 right3 case3 zero suc rec)

zero3  : ∀{Γ} → Tm3 Γ nat3; zero3
 = λ Tm3 var3 lam3 app3 tt3 pair3 fst3 snd3 left3 right3 case3 zero3 suc rec → zero3

suc3 : ∀{Γ} → Tm3 Γ nat3 → Tm3 Γ nat3; suc3
 = λ t Tm3 var3 lam3 app3 tt3 pair3 fst3 snd3 left3 right3 case3 zero3 suc3 rec →
   suc3 (t Tm3 var3 lam3 app3 tt3 pair3 fst3 snd3 left3 right3 case3 zero3 suc3 rec)

rec3 : ∀{Γ A} → Tm3 Γ nat3 → Tm3 Γ (arr3 nat3 (arr3 A A)) → Tm3 Γ A → Tm3 Γ A; rec3
 = λ t u v Tm3 var3 lam3 app3 tt3 pair3 fst3 snd3 left3 right3 case3 zero3 suc3 rec3 →
     rec3 (t Tm3 var3 lam3 app3 tt3 pair3 fst3 snd3 left3 right3 case3 zero3 suc3 rec3)
         (u Tm3 var3 lam3 app3 tt3 pair3 fst3 snd3 left3 right3 case3 zero3 suc3 rec3)
         (v Tm3 var3 lam3 app3 tt3 pair3 fst3 snd3 left3 right3 case3 zero3 suc3 rec3)

v03 : ∀{Γ A} → Tm3 (snoc3 Γ A) A; v03
 = var3 vz3

v13 : ∀{Γ A B} → Tm3 (snoc3 (snoc3 Γ A) B) A; v13
 = var3 (vs3 vz3)

v23 : ∀{Γ A B C} → Tm3 (snoc3 (snoc3 (snoc3 Γ A) B) C) A; v23
 = var3 (vs3 (vs3 vz3))

v33 : ∀{Γ A B C D} → Tm3 (snoc3 (snoc3 (snoc3 (snoc3 Γ A) B) C) D) A; v33
 = var3 (vs3 (vs3 (vs3 vz3)))

tbool3 : Ty3; tbool3
 = sum3 top3 top3

true3 : ∀{Γ} → Tm3 Γ tbool3; true3
 = left3 tt3

tfalse3 : ∀{Γ} → Tm3 Γ tbool3; tfalse3
 = right3 tt3

ifthenelse3 : ∀{Γ A} → Tm3 Γ (arr3 tbool3 (arr3 A (arr3 A A))); ifthenelse3
 = lam3 (lam3 (lam3 (case3 v23 (lam3 v23) (lam3 v13))))

times43 : ∀{Γ A} → Tm3 Γ (arr3 (arr3 A A) (arr3 A A)); times43
  = lam3 (lam3 (app3 v13 (app3 v13 (app3 v13 (app3 v13 v03)))))

add3 : ∀{Γ} → Tm3 Γ (arr3 nat3 (arr3 nat3 nat3)); add3
 = lam3 (rec3 v03
       (lam3 (lam3 (lam3 (suc3 (app3 v13 v03)))))
       (lam3 v03))

mul3 : ∀{Γ} → Tm3 Γ (arr3 nat3 (arr3 nat3 nat3)); mul3
 = lam3 (rec3 v03
       (lam3 (lam3 (lam3 (app3 (app3 add3 (app3 v13 v03)) v03))))
       (lam3 zero3))

fact3 : ∀{Γ} → Tm3 Γ (arr3 nat3 nat3); fact3
 = lam3 (rec3 v03 (lam3 (lam3 (app3 (app3 mul3 (suc3 v13)) v03)))
        (suc3 zero3))
{-# OPTIONS --type-in-type #-}

Ty4 : Set
Ty4 =
   (Ty4         : Set)
   (nat top bot  : Ty4)
   (arr prod sum : Ty4 → Ty4 → Ty4)
 → Ty4

nat4 : Ty4; nat4 = λ _ nat4 _ _ _ _ _ → nat4
top4 : Ty4; top4 = λ _ _ top4 _ _ _ _ → top4
bot4 : Ty4; bot4 = λ _ _ _ bot4 _ _ _ → bot4

arr4 : Ty4 → Ty4 → Ty4; arr4
 = λ A B Ty4 nat4 top4 bot4 arr4 prod sum →
     arr4 (A Ty4 nat4 top4 bot4 arr4 prod sum) (B Ty4 nat4 top4 bot4 arr4 prod sum)

prod4 : Ty4 → Ty4 → Ty4; prod4
 = λ A B Ty4 nat4 top4 bot4 arr4 prod4 sum →
     prod4 (A Ty4 nat4 top4 bot4 arr4 prod4 sum) (B Ty4 nat4 top4 bot4 arr4 prod4 sum)

sum4 : Ty4 → Ty4 → Ty4; sum4
 = λ A B Ty4 nat4 top4 bot4 arr4 prod4 sum4 →
     sum4 (A Ty4 nat4 top4 bot4 arr4 prod4 sum4) (B Ty4 nat4 top4 bot4 arr4 prod4 sum4)

Con4 : Set; Con4
 = (Con4 : Set)
   (nil  : Con4)
   (snoc : Con4 → Ty4 → Con4)
 → Con4

nil4 : Con4; nil4
 = λ Con4 nil4 snoc → nil4

snoc4 : Con4 → Ty4 → Con4; snoc4
 = λ Γ A Con4 nil4 snoc4 → snoc4 (Γ Con4 nil4 snoc4) A

Var4 : Con4 → Ty4 → Set; Var4
 = λ Γ A →
   (Var4 : Con4 → Ty4 → Set)
   (vz  : ∀{Γ A} → Var4 (snoc4 Γ A) A)
   (vs  : ∀{Γ B A} → Var4 Γ A → Var4 (snoc4 Γ B) A)
 → Var4 Γ A

vz4 : ∀{Γ A} → Var4 (snoc4 Γ A) A; vz4
 = λ Var4 vz4 vs → vz4

vs4 : ∀{Γ B A} → Var4 Γ A → Var4 (snoc4 Γ B) A; vs4
 = λ x Var4 vz4 vs4 → vs4 (x Var4 vz4 vs4)

Tm4 : Con4 → Ty4 → Set; Tm4
 = λ Γ A →
   (Tm4  : Con4 → Ty4 → Set)
   (var   : ∀{Γ A} → Var4 Γ A → Tm4 Γ A)
   (lam   : ∀{Γ A B} → Tm4 (snoc4 Γ A) B → Tm4 Γ (arr4 A B))
   (app   : ∀{Γ A B} → Tm4 Γ (arr4 A B) → Tm4 Γ A → Tm4 Γ B)
   (tt    : ∀{Γ} → Tm4 Γ top4)
   (pair  : ∀{Γ A B} → Tm4 Γ A → Tm4 Γ B → Tm4 Γ (prod4 A B))
   (fst   : ∀{Γ A B} → Tm4 Γ (prod4 A B) → Tm4 Γ A)
   (snd   : ∀{Γ A B} → Tm4 Γ (prod4 A B) → Tm4 Γ B)
   (left  : ∀{Γ A B} → Tm4 Γ A → Tm4 Γ (sum4 A B))
   (right : ∀{Γ A B} → Tm4 Γ B → Tm4 Γ (sum4 A B))
   (case  : ∀{Γ A B C} → Tm4 Γ (sum4 A B) → Tm4 Γ (arr4 A C) → Tm4 Γ (arr4 B C) → Tm4 Γ C)
   (zero  : ∀{Γ} → Tm4 Γ nat4)
   (suc   : ∀{Γ} → Tm4 Γ nat4 → Tm4 Γ nat4)
   (rec   : ∀{Γ A} → Tm4 Γ nat4 → Tm4 Γ (arr4 nat4 (arr4 A A)) → Tm4 Γ A → Tm4 Γ A)
 → Tm4 Γ A

var4 : ∀{Γ A} → Var4 Γ A → Tm4 Γ A; var4
 = λ x Tm4 var4 lam app tt pair fst snd left right case zero suc rec →
     var4 x

lam4 : ∀{Γ A B} → Tm4 (snoc4 Γ A) B → Tm4 Γ (arr4 A B); lam4
 = λ t Tm4 var4 lam4 app tt pair fst snd left right case zero suc rec →
     lam4 (t Tm4 var4 lam4 app tt pair fst snd left right case zero suc rec)

app4 : ∀{Γ A B} → Tm4 Γ (arr4 A B) → Tm4 Γ A → Tm4 Γ B; app4
 = λ t u Tm4 var4 lam4 app4 tt pair fst snd left right case zero suc rec →
     app4 (t Tm4 var4 lam4 app4 tt pair fst snd left right case zero suc rec)
         (u Tm4 var4 lam4 app4 tt pair fst snd left right case zero suc rec)

tt4 : ∀{Γ} → Tm4 Γ top4; tt4
 = λ Tm4 var4 lam4 app4 tt4 pair fst snd left right case zero suc rec → tt4

pair4 : ∀{Γ A B} → Tm4 Γ A → Tm4 Γ B → Tm4 Γ (prod4 A B); pair4
 = λ t u Tm4 var4 lam4 app4 tt4 pair4 fst snd left right case zero suc rec →
     pair4 (t Tm4 var4 lam4 app4 tt4 pair4 fst snd left right case zero suc rec)
          (u Tm4 var4 lam4 app4 tt4 pair4 fst snd left right case zero suc rec)

fst4 : ∀{Γ A B} → Tm4 Γ (prod4 A B) → Tm4 Γ A; fst4
 = λ t Tm4 var4 lam4 app4 tt4 pair4 fst4 snd left right case zero suc rec →
     fst4 (t Tm4 var4 lam4 app4 tt4 pair4 fst4 snd left right case zero suc rec)

snd4 : ∀{Γ A B} → Tm4 Γ (prod4 A B) → Tm4 Γ B; snd4
 = λ t Tm4 var4 lam4 app4 tt4 pair4 fst4 snd4 left right case zero suc rec →
     snd4 (t Tm4 var4 lam4 app4 tt4 pair4 fst4 snd4 left right case zero suc rec)

left4 : ∀{Γ A B} → Tm4 Γ A → Tm4 Γ (sum4 A B); left4
 = λ t Tm4 var4 lam4 app4 tt4 pair4 fst4 snd4 left4 right case zero suc rec →
     left4 (t Tm4 var4 lam4 app4 tt4 pair4 fst4 snd4 left4 right case zero suc rec)

right4 : ∀{Γ A B} → Tm4 Γ B → Tm4 Γ (sum4 A B); right4
 = λ t Tm4 var4 lam4 app4 tt4 pair4 fst4 snd4 left4 right4 case zero suc rec →
     right4 (t Tm4 var4 lam4 app4 tt4 pair4 fst4 snd4 left4 right4 case zero suc rec)

case4 : ∀{Γ A B C} → Tm4 Γ (sum4 A B) → Tm4 Γ (arr4 A C) → Tm4 Γ (arr4 B C) → Tm4 Γ C; case4
 = λ t u v Tm4 var4 lam4 app4 tt4 pair4 fst4 snd4 left4 right4 case4 zero suc rec →
     case4 (t Tm4 var4 lam4 app4 tt4 pair4 fst4 snd4 left4 right4 case4 zero suc rec)
           (u Tm4 var4 lam4 app4 tt4 pair4 fst4 snd4 left4 right4 case4 zero suc rec)
           (v Tm4 var4 lam4 app4 tt4 pair4 fst4 snd4 left4 right4 case4 zero suc rec)

zero4  : ∀{Γ} → Tm4 Γ nat4; zero4
 = λ Tm4 var4 lam4 app4 tt4 pair4 fst4 snd4 left4 right4 case4 zero4 suc rec → zero4

suc4 : ∀{Γ} → Tm4 Γ nat4 → Tm4 Γ nat4; suc4
 = λ t Tm4 var4 lam4 app4 tt4 pair4 fst4 snd4 left4 right4 case4 zero4 suc4 rec →
   suc4 (t Tm4 var4 lam4 app4 tt4 pair4 fst4 snd4 left4 right4 case4 zero4 suc4 rec)

rec4 : ∀{Γ A} → Tm4 Γ nat4 → Tm4 Γ (arr4 nat4 (arr4 A A)) → Tm4 Γ A → Tm4 Γ A; rec4
 = λ t u v Tm4 var4 lam4 app4 tt4 pair4 fst4 snd4 left4 right4 case4 zero4 suc4 rec4 →
     rec4 (t Tm4 var4 lam4 app4 tt4 pair4 fst4 snd4 left4 right4 case4 zero4 suc4 rec4)
         (u Tm4 var4 lam4 app4 tt4 pair4 fst4 snd4 left4 right4 case4 zero4 suc4 rec4)
         (v Tm4 var4 lam4 app4 tt4 pair4 fst4 snd4 left4 right4 case4 zero4 suc4 rec4)

v04 : ∀{Γ A} → Tm4 (snoc4 Γ A) A; v04
 = var4 vz4

v14 : ∀{Γ A B} → Tm4 (snoc4 (snoc4 Γ A) B) A; v14
 = var4 (vs4 vz4)

v24 : ∀{Γ A B C} → Tm4 (snoc4 (snoc4 (snoc4 Γ A) B) C) A; v24
 = var4 (vs4 (vs4 vz4))

v34 : ∀{Γ A B C D} → Tm4 (snoc4 (snoc4 (snoc4 (snoc4 Γ A) B) C) D) A; v34
 = var4 (vs4 (vs4 (vs4 vz4)))

tbool4 : Ty4; tbool4
 = sum4 top4 top4

true4 : ∀{Γ} → Tm4 Γ tbool4; true4
 = left4 tt4

tfalse4 : ∀{Γ} → Tm4 Γ tbool4; tfalse4
 = right4 tt4

ifthenelse4 : ∀{Γ A} → Tm4 Γ (arr4 tbool4 (arr4 A (arr4 A A))); ifthenelse4
 = lam4 (lam4 (lam4 (case4 v24 (lam4 v24) (lam4 v14))))

times44 : ∀{Γ A} → Tm4 Γ (arr4 (arr4 A A) (arr4 A A)); times44
  = lam4 (lam4 (app4 v14 (app4 v14 (app4 v14 (app4 v14 v04)))))

add4 : ∀{Γ} → Tm4 Γ (arr4 nat4 (arr4 nat4 nat4)); add4
 = lam4 (rec4 v04
       (lam4 (lam4 (lam4 (suc4 (app4 v14 v04)))))
       (lam4 v04))

mul4 : ∀{Γ} → Tm4 Γ (arr4 nat4 (arr4 nat4 nat4)); mul4
 = lam4 (rec4 v04
       (lam4 (lam4 (lam4 (app4 (app4 add4 (app4 v14 v04)) v04))))
       (lam4 zero4))

fact4 : ∀{Γ} → Tm4 Γ (arr4 nat4 nat4); fact4
 = lam4 (rec4 v04 (lam4 (lam4 (app4 (app4 mul4 (suc4 v14)) v04)))
        (suc4 zero4))
{-# OPTIONS --type-in-type #-}

Ty5 : Set
Ty5 =
   (Ty5         : Set)
   (nat top bot  : Ty5)
   (arr prod sum : Ty5 → Ty5 → Ty5)
 → Ty5

nat5 : Ty5; nat5 = λ _ nat5 _ _ _ _ _ → nat5
top5 : Ty5; top5 = λ _ _ top5 _ _ _ _ → top5
bot5 : Ty5; bot5 = λ _ _ _ bot5 _ _ _ → bot5

arr5 : Ty5 → Ty5 → Ty5; arr5
 = λ A B Ty5 nat5 top5 bot5 arr5 prod sum →
     arr5 (A Ty5 nat5 top5 bot5 arr5 prod sum) (B Ty5 nat5 top5 bot5 arr5 prod sum)

prod5 : Ty5 → Ty5 → Ty5; prod5
 = λ A B Ty5 nat5 top5 bot5 arr5 prod5 sum →
     prod5 (A Ty5 nat5 top5 bot5 arr5 prod5 sum) (B Ty5 nat5 top5 bot5 arr5 prod5 sum)

sum5 : Ty5 → Ty5 → Ty5; sum5
 = λ A B Ty5 nat5 top5 bot5 arr5 prod5 sum5 →
     sum5 (A Ty5 nat5 top5 bot5 arr5 prod5 sum5) (B Ty5 nat5 top5 bot5 arr5 prod5 sum5)

Con5 : Set; Con5
 = (Con5 : Set)
   (nil  : Con5)
   (snoc : Con5 → Ty5 → Con5)
 → Con5

nil5 : Con5; nil5
 = λ Con5 nil5 snoc → nil5

snoc5 : Con5 → Ty5 → Con5; snoc5
 = λ Γ A Con5 nil5 snoc5 → snoc5 (Γ Con5 nil5 snoc5) A

Var5 : Con5 → Ty5 → Set; Var5
 = λ Γ A →
   (Var5 : Con5 → Ty5 → Set)
   (vz  : ∀{Γ A} → Var5 (snoc5 Γ A) A)
   (vs  : ∀{Γ B A} → Var5 Γ A → Var5 (snoc5 Γ B) A)
 → Var5 Γ A

vz5 : ∀{Γ A} → Var5 (snoc5 Γ A) A; vz5
 = λ Var5 vz5 vs → vz5

vs5 : ∀{Γ B A} → Var5 Γ A → Var5 (snoc5 Γ B) A; vs5
 = λ x Var5 vz5 vs5 → vs5 (x Var5 vz5 vs5)

Tm5 : Con5 → Ty5 → Set; Tm5
 = λ Γ A →
   (Tm5  : Con5 → Ty5 → Set)
   (var   : ∀{Γ A} → Var5 Γ A → Tm5 Γ A)
   (lam   : ∀{Γ A B} → Tm5 (snoc5 Γ A) B → Tm5 Γ (arr5 A B))
   (app   : ∀{Γ A B} → Tm5 Γ (arr5 A B) → Tm5 Γ A → Tm5 Γ B)
   (tt    : ∀{Γ} → Tm5 Γ top5)
   (pair  : ∀{Γ A B} → Tm5 Γ A → Tm5 Γ B → Tm5 Γ (prod5 A B))
   (fst   : ∀{Γ A B} → Tm5 Γ (prod5 A B) → Tm5 Γ A)
   (snd   : ∀{Γ A B} → Tm5 Γ (prod5 A B) → Tm5 Γ B)
   (left  : ∀{Γ A B} → Tm5 Γ A → Tm5 Γ (sum5 A B))
   (right : ∀{Γ A B} → Tm5 Γ B → Tm5 Γ (sum5 A B))
   (case  : ∀{Γ A B C} → Tm5 Γ (sum5 A B) → Tm5 Γ (arr5 A C) → Tm5 Γ (arr5 B C) → Tm5 Γ C)
   (zero  : ∀{Γ} → Tm5 Γ nat5)
   (suc   : ∀{Γ} → Tm5 Γ nat5 → Tm5 Γ nat5)
   (rec   : ∀{Γ A} → Tm5 Γ nat5 → Tm5 Γ (arr5 nat5 (arr5 A A)) → Tm5 Γ A → Tm5 Γ A)
 → Tm5 Γ A

var5 : ∀{Γ A} → Var5 Γ A → Tm5 Γ A; var5
 = λ x Tm5 var5 lam app tt pair fst snd left right case zero suc rec →
     var5 x

lam5 : ∀{Γ A B} → Tm5 (snoc5 Γ A) B → Tm5 Γ (arr5 A B); lam5
 = λ t Tm5 var5 lam5 app tt pair fst snd left right case zero suc rec →
     lam5 (t Tm5 var5 lam5 app tt pair fst snd left right case zero suc rec)

app5 : ∀{Γ A B} → Tm5 Γ (arr5 A B) → Tm5 Γ A → Tm5 Γ B; app5
 = λ t u Tm5 var5 lam5 app5 tt pair fst snd left right case zero suc rec →
     app5 (t Tm5 var5 lam5 app5 tt pair fst snd left right case zero suc rec)
         (u Tm5 var5 lam5 app5 tt pair fst snd left right case zero suc rec)

tt5 : ∀{Γ} → Tm5 Γ top5; tt5
 = λ Tm5 var5 lam5 app5 tt5 pair fst snd left right case zero suc rec → tt5

pair5 : ∀{Γ A B} → Tm5 Γ A → Tm5 Γ B → Tm5 Γ (prod5 A B); pair5
 = λ t u Tm5 var5 lam5 app5 tt5 pair5 fst snd left right case zero suc rec →
     pair5 (t Tm5 var5 lam5 app5 tt5 pair5 fst snd left right case zero suc rec)
          (u Tm5 var5 lam5 app5 tt5 pair5 fst snd left right case zero suc rec)

fst5 : ∀{Γ A B} → Tm5 Γ (prod5 A B) → Tm5 Γ A; fst5
 = λ t Tm5 var5 lam5 app5 tt5 pair5 fst5 snd left right case zero suc rec →
     fst5 (t Tm5 var5 lam5 app5 tt5 pair5 fst5 snd left right case zero suc rec)

snd5 : ∀{Γ A B} → Tm5 Γ (prod5 A B) → Tm5 Γ B; snd5
 = λ t Tm5 var5 lam5 app5 tt5 pair5 fst5 snd5 left right case zero suc rec →
     snd5 (t Tm5 var5 lam5 app5 tt5 pair5 fst5 snd5 left right case zero suc rec)

left5 : ∀{Γ A B} → Tm5 Γ A → Tm5 Γ (sum5 A B); left5
 = λ t Tm5 var5 lam5 app5 tt5 pair5 fst5 snd5 left5 right case zero suc rec →
     left5 (t Tm5 var5 lam5 app5 tt5 pair5 fst5 snd5 left5 right case zero suc rec)

right5 : ∀{Γ A B} → Tm5 Γ B → Tm5 Γ (sum5 A B); right5
 = λ t Tm5 var5 lam5 app5 tt5 pair5 fst5 snd5 left5 right5 case zero suc rec →
     right5 (t Tm5 var5 lam5 app5 tt5 pair5 fst5 snd5 left5 right5 case zero suc rec)

case5 : ∀{Γ A B C} → Tm5 Γ (sum5 A B) → Tm5 Γ (arr5 A C) → Tm5 Γ (arr5 B C) → Tm5 Γ C; case5
 = λ t u v Tm5 var5 lam5 app5 tt5 pair5 fst5 snd5 left5 right5 case5 zero suc rec →
     case5 (t Tm5 var5 lam5 app5 tt5 pair5 fst5 snd5 left5 right5 case5 zero suc rec)
           (u Tm5 var5 lam5 app5 tt5 pair5 fst5 snd5 left5 right5 case5 zero suc rec)
           (v Tm5 var5 lam5 app5 tt5 pair5 fst5 snd5 left5 right5 case5 zero suc rec)

zero5  : ∀{Γ} → Tm5 Γ nat5; zero5
 = λ Tm5 var5 lam5 app5 tt5 pair5 fst5 snd5 left5 right5 case5 zero5 suc rec → zero5

suc5 : ∀{Γ} → Tm5 Γ nat5 → Tm5 Γ nat5; suc5
 = λ t Tm5 var5 lam5 app5 tt5 pair5 fst5 snd5 left5 right5 case5 zero5 suc5 rec →
   suc5 (t Tm5 var5 lam5 app5 tt5 pair5 fst5 snd5 left5 right5 case5 zero5 suc5 rec)

rec5 : ∀{Γ A} → Tm5 Γ nat5 → Tm5 Γ (arr5 nat5 (arr5 A A)) → Tm5 Γ A → Tm5 Γ A; rec5
 = λ t u v Tm5 var5 lam5 app5 tt5 pair5 fst5 snd5 left5 right5 case5 zero5 suc5 rec5 →
     rec5 (t Tm5 var5 lam5 app5 tt5 pair5 fst5 snd5 left5 right5 case5 zero5 suc5 rec5)
         (u Tm5 var5 lam5 app5 tt5 pair5 fst5 snd5 left5 right5 case5 zero5 suc5 rec5)
         (v Tm5 var5 lam5 app5 tt5 pair5 fst5 snd5 left5 right5 case5 zero5 suc5 rec5)

v05 : ∀{Γ A} → Tm5 (snoc5 Γ A) A; v05
 = var5 vz5

v15 : ∀{Γ A B} → Tm5 (snoc5 (snoc5 Γ A) B) A; v15
 = var5 (vs5 vz5)

v25 : ∀{Γ A B C} → Tm5 (snoc5 (snoc5 (snoc5 Γ A) B) C) A; v25
 = var5 (vs5 (vs5 vz5))

v35 : ∀{Γ A B C D} → Tm5 (snoc5 (snoc5 (snoc5 (snoc5 Γ A) B) C) D) A; v35
 = var5 (vs5 (vs5 (vs5 vz5)))

tbool5 : Ty5; tbool5
 = sum5 top5 top5

true5 : ∀{Γ} → Tm5 Γ tbool5; true5
 = left5 tt5

tfalse5 : ∀{Γ} → Tm5 Γ tbool5; tfalse5
 = right5 tt5

ifthenelse5 : ∀{Γ A} → Tm5 Γ (arr5 tbool5 (arr5 A (arr5 A A))); ifthenelse5
 = lam5 (lam5 (lam5 (case5 v25 (lam5 v25) (lam5 v15))))

times45 : ∀{Γ A} → Tm5 Γ (arr5 (arr5 A A) (arr5 A A)); times45
  = lam5 (lam5 (app5 v15 (app5 v15 (app5 v15 (app5 v15 v05)))))

add5 : ∀{Γ} → Tm5 Γ (arr5 nat5 (arr5 nat5 nat5)); add5
 = lam5 (rec5 v05
       (lam5 (lam5 (lam5 (suc5 (app5 v15 v05)))))
       (lam5 v05))

mul5 : ∀{Γ} → Tm5 Γ (arr5 nat5 (arr5 nat5 nat5)); mul5
 = lam5 (rec5 v05
       (lam5 (lam5 (lam5 (app5 (app5 add5 (app5 v15 v05)) v05))))
       (lam5 zero5))

fact5 : ∀{Γ} → Tm5 Γ (arr5 nat5 nat5); fact5
 = lam5 (rec5 v05 (lam5 (lam5 (app5 (app5 mul5 (suc5 v15)) v05)))
        (suc5 zero5))
{-# OPTIONS --type-in-type #-}

Ty6 : Set
Ty6 =
   (Ty6         : Set)
   (nat top bot  : Ty6)
   (arr prod sum : Ty6 → Ty6 → Ty6)
 → Ty6

nat6 : Ty6; nat6 = λ _ nat6 _ _ _ _ _ → nat6
top6 : Ty6; top6 = λ _ _ top6 _ _ _ _ → top6
bot6 : Ty6; bot6 = λ _ _ _ bot6 _ _ _ → bot6

arr6 : Ty6 → Ty6 → Ty6; arr6
 = λ A B Ty6 nat6 top6 bot6 arr6 prod sum →
     arr6 (A Ty6 nat6 top6 bot6 arr6 prod sum) (B Ty6 nat6 top6 bot6 arr6 prod sum)

prod6 : Ty6 → Ty6 → Ty6; prod6
 = λ A B Ty6 nat6 top6 bot6 arr6 prod6 sum →
     prod6 (A Ty6 nat6 top6 bot6 arr6 prod6 sum) (B Ty6 nat6 top6 bot6 arr6 prod6 sum)

sum6 : Ty6 → Ty6 → Ty6; sum6
 = λ A B Ty6 nat6 top6 bot6 arr6 prod6 sum6 →
     sum6 (A Ty6 nat6 top6 bot6 arr6 prod6 sum6) (B Ty6 nat6 top6 bot6 arr6 prod6 sum6)

Con6 : Set; Con6
 = (Con6 : Set)
   (nil  : Con6)
   (snoc : Con6 → Ty6 → Con6)
 → Con6

nil6 : Con6; nil6
 = λ Con6 nil6 snoc → nil6

snoc6 : Con6 → Ty6 → Con6; snoc6
 = λ Γ A Con6 nil6 snoc6 → snoc6 (Γ Con6 nil6 snoc6) A

Var6 : Con6 → Ty6 → Set; Var6
 = λ Γ A →
   (Var6 : Con6 → Ty6 → Set)
   (vz  : ∀{Γ A} → Var6 (snoc6 Γ A) A)
   (vs  : ∀{Γ B A} → Var6 Γ A → Var6 (snoc6 Γ B) A)
 → Var6 Γ A

vz6 : ∀{Γ A} → Var6 (snoc6 Γ A) A; vz6
 = λ Var6 vz6 vs → vz6

vs6 : ∀{Γ B A} → Var6 Γ A → Var6 (snoc6 Γ B) A; vs6
 = λ x Var6 vz6 vs6 → vs6 (x Var6 vz6 vs6)

Tm6 : Con6 → Ty6 → Set; Tm6
 = λ Γ A →
   (Tm6  : Con6 → Ty6 → Set)
   (var   : ∀{Γ A} → Var6 Γ A → Tm6 Γ A)
   (lam   : ∀{Γ A B} → Tm6 (snoc6 Γ A) B → Tm6 Γ (arr6 A B))
   (app   : ∀{Γ A B} → Tm6 Γ (arr6 A B) → Tm6 Γ A → Tm6 Γ B)
   (tt    : ∀{Γ} → Tm6 Γ top6)
   (pair  : ∀{Γ A B} → Tm6 Γ A → Tm6 Γ B → Tm6 Γ (prod6 A B))
   (fst   : ∀{Γ A B} → Tm6 Γ (prod6 A B) → Tm6 Γ A)
   (snd   : ∀{Γ A B} → Tm6 Γ (prod6 A B) → Tm6 Γ B)
   (left  : ∀{Γ A B} → Tm6 Γ A → Tm6 Γ (sum6 A B))
   (right : ∀{Γ A B} → Tm6 Γ B → Tm6 Γ (sum6 A B))
   (case  : ∀{Γ A B C} → Tm6 Γ (sum6 A B) → Tm6 Γ (arr6 A C) → Tm6 Γ (arr6 B C) → Tm6 Γ C)
   (zero  : ∀{Γ} → Tm6 Γ nat6)
   (suc   : ∀{Γ} → Tm6 Γ nat6 → Tm6 Γ nat6)
   (rec   : ∀{Γ A} → Tm6 Γ nat6 → Tm6 Γ (arr6 nat6 (arr6 A A)) → Tm6 Γ A → Tm6 Γ A)
 → Tm6 Γ A

var6 : ∀{Γ A} → Var6 Γ A → Tm6 Γ A; var6
 = λ x Tm6 var6 lam app tt pair fst snd left right case zero suc rec →
     var6 x

lam6 : ∀{Γ A B} → Tm6 (snoc6 Γ A) B → Tm6 Γ (arr6 A B); lam6
 = λ t Tm6 var6 lam6 app tt pair fst snd left right case zero suc rec →
     lam6 (t Tm6 var6 lam6 app tt pair fst snd left right case zero suc rec)

app6 : ∀{Γ A B} → Tm6 Γ (arr6 A B) → Tm6 Γ A → Tm6 Γ B; app6
 = λ t u Tm6 var6 lam6 app6 tt pair fst snd left right case zero suc rec →
     app6 (t Tm6 var6 lam6 app6 tt pair fst snd left right case zero suc rec)
         (u Tm6 var6 lam6 app6 tt pair fst snd left right case zero suc rec)

tt6 : ∀{Γ} → Tm6 Γ top6; tt6
 = λ Tm6 var6 lam6 app6 tt6 pair fst snd left right case zero suc rec → tt6

pair6 : ∀{Γ A B} → Tm6 Γ A → Tm6 Γ B → Tm6 Γ (prod6 A B); pair6
 = λ t u Tm6 var6 lam6 app6 tt6 pair6 fst snd left right case zero suc rec →
     pair6 (t Tm6 var6 lam6 app6 tt6 pair6 fst snd left right case zero suc rec)
          (u Tm6 var6 lam6 app6 tt6 pair6 fst snd left right case zero suc rec)

fst6 : ∀{Γ A B} → Tm6 Γ (prod6 A B) → Tm6 Γ A; fst6
 = λ t Tm6 var6 lam6 app6 tt6 pair6 fst6 snd left right case zero suc rec →
     fst6 (t Tm6 var6 lam6 app6 tt6 pair6 fst6 snd left right case zero suc rec)

snd6 : ∀{Γ A B} → Tm6 Γ (prod6 A B) → Tm6 Γ B; snd6
 = λ t Tm6 var6 lam6 app6 tt6 pair6 fst6 snd6 left right case zero suc rec →
     snd6 (t Tm6 var6 lam6 app6 tt6 pair6 fst6 snd6 left right case zero suc rec)

left6 : ∀{Γ A B} → Tm6 Γ A → Tm6 Γ (sum6 A B); left6
 = λ t Tm6 var6 lam6 app6 tt6 pair6 fst6 snd6 left6 right case zero suc rec →
     left6 (t Tm6 var6 lam6 app6 tt6 pair6 fst6 snd6 left6 right case zero suc rec)

right6 : ∀{Γ A B} → Tm6 Γ B → Tm6 Γ (sum6 A B); right6
 = λ t Tm6 var6 lam6 app6 tt6 pair6 fst6 snd6 left6 right6 case zero suc rec →
     right6 (t Tm6 var6 lam6 app6 tt6 pair6 fst6 snd6 left6 right6 case zero suc rec)

case6 : ∀{Γ A B C} → Tm6 Γ (sum6 A B) → Tm6 Γ (arr6 A C) → Tm6 Γ (arr6 B C) → Tm6 Γ C; case6
 = λ t u v Tm6 var6 lam6 app6 tt6 pair6 fst6 snd6 left6 right6 case6 zero suc rec →
     case6 (t Tm6 var6 lam6 app6 tt6 pair6 fst6 snd6 left6 right6 case6 zero suc rec)
           (u Tm6 var6 lam6 app6 tt6 pair6 fst6 snd6 left6 right6 case6 zero suc rec)
           (v Tm6 var6 lam6 app6 tt6 pair6 fst6 snd6 left6 right6 case6 zero suc rec)

zero6  : ∀{Γ} → Tm6 Γ nat6; zero6
 = λ Tm6 var6 lam6 app6 tt6 pair6 fst6 snd6 left6 right6 case6 zero6 suc rec → zero6

suc6 : ∀{Γ} → Tm6 Γ nat6 → Tm6 Γ nat6; suc6
 = λ t Tm6 var6 lam6 app6 tt6 pair6 fst6 snd6 left6 right6 case6 zero6 suc6 rec →
   suc6 (t Tm6 var6 lam6 app6 tt6 pair6 fst6 snd6 left6 right6 case6 zero6 suc6 rec)

rec6 : ∀{Γ A} → Tm6 Γ nat6 → Tm6 Γ (arr6 nat6 (arr6 A A)) → Tm6 Γ A → Tm6 Γ A; rec6
 = λ t u v Tm6 var6 lam6 app6 tt6 pair6 fst6 snd6 left6 right6 case6 zero6 suc6 rec6 →
     rec6 (t Tm6 var6 lam6 app6 tt6 pair6 fst6 snd6 left6 right6 case6 zero6 suc6 rec6)
         (u Tm6 var6 lam6 app6 tt6 pair6 fst6 snd6 left6 right6 case6 zero6 suc6 rec6)
         (v Tm6 var6 lam6 app6 tt6 pair6 fst6 snd6 left6 right6 case6 zero6 suc6 rec6)

v06 : ∀{Γ A} → Tm6 (snoc6 Γ A) A; v06
 = var6 vz6

v16 : ∀{Γ A B} → Tm6 (snoc6 (snoc6 Γ A) B) A; v16
 = var6 (vs6 vz6)

v26 : ∀{Γ A B C} → Tm6 (snoc6 (snoc6 (snoc6 Γ A) B) C) A; v26
 = var6 (vs6 (vs6 vz6))

v36 : ∀{Γ A B C D} → Tm6 (snoc6 (snoc6 (snoc6 (snoc6 Γ A) B) C) D) A; v36
 = var6 (vs6 (vs6 (vs6 vz6)))

tbool6 : Ty6; tbool6
 = sum6 top6 top6

true6 : ∀{Γ} → Tm6 Γ tbool6; true6
 = left6 tt6

tfalse6 : ∀{Γ} → Tm6 Γ tbool6; tfalse6
 = right6 tt6

ifthenelse6 : ∀{Γ A} → Tm6 Γ (arr6 tbool6 (arr6 A (arr6 A A))); ifthenelse6
 = lam6 (lam6 (lam6 (case6 v26 (lam6 v26) (lam6 v16))))

times46 : ∀{Γ A} → Tm6 Γ (arr6 (arr6 A A) (arr6 A A)); times46
  = lam6 (lam6 (app6 v16 (app6 v16 (app6 v16 (app6 v16 v06)))))

add6 : ∀{Γ} → Tm6 Γ (arr6 nat6 (arr6 nat6 nat6)); add6
 = lam6 (rec6 v06
       (lam6 (lam6 (lam6 (suc6 (app6 v16 v06)))))
       (lam6 v06))

mul6 : ∀{Γ} → Tm6 Γ (arr6 nat6 (arr6 nat6 nat6)); mul6
 = lam6 (rec6 v06
       (lam6 (lam6 (lam6 (app6 (app6 add6 (app6 v16 v06)) v06))))
       (lam6 zero6))

fact6 : ∀{Γ} → Tm6 Γ (arr6 nat6 nat6); fact6
 = lam6 (rec6 v06 (lam6 (lam6 (app6 (app6 mul6 (suc6 v16)) v06)))
        (suc6 zero6))
{-# OPTIONS --type-in-type #-}

Ty7 : Set
Ty7 =
   (Ty7         : Set)
   (nat top bot  : Ty7)
   (arr prod sum : Ty7 → Ty7 → Ty7)
 → Ty7

nat7 : Ty7; nat7 = λ _ nat7 _ _ _ _ _ → nat7
top7 : Ty7; top7 = λ _ _ top7 _ _ _ _ → top7
bot7 : Ty7; bot7 = λ _ _ _ bot7 _ _ _ → bot7

arr7 : Ty7 → Ty7 → Ty7; arr7
 = λ A B Ty7 nat7 top7 bot7 arr7 prod sum →
     arr7 (A Ty7 nat7 top7 bot7 arr7 prod sum) (B Ty7 nat7 top7 bot7 arr7 prod sum)

prod7 : Ty7 → Ty7 → Ty7; prod7
 = λ A B Ty7 nat7 top7 bot7 arr7 prod7 sum →
     prod7 (A Ty7 nat7 top7 bot7 arr7 prod7 sum) (B Ty7 nat7 top7 bot7 arr7 prod7 sum)

sum7 : Ty7 → Ty7 → Ty7; sum7
 = λ A B Ty7 nat7 top7 bot7 arr7 prod7 sum7 →
     sum7 (A Ty7 nat7 top7 bot7 arr7 prod7 sum7) (B Ty7 nat7 top7 bot7 arr7 prod7 sum7)

Con7 : Set; Con7
 = (Con7 : Set)
   (nil  : Con7)
   (snoc : Con7 → Ty7 → Con7)
 → Con7

nil7 : Con7; nil7
 = λ Con7 nil7 snoc → nil7

snoc7 : Con7 → Ty7 → Con7; snoc7
 = λ Γ A Con7 nil7 snoc7 → snoc7 (Γ Con7 nil7 snoc7) A

Var7 : Con7 → Ty7 → Set; Var7
 = λ Γ A →
   (Var7 : Con7 → Ty7 → Set)
   (vz  : ∀{Γ A} → Var7 (snoc7 Γ A) A)
   (vs  : ∀{Γ B A} → Var7 Γ A → Var7 (snoc7 Γ B) A)
 → Var7 Γ A

vz7 : ∀{Γ A} → Var7 (snoc7 Γ A) A; vz7
 = λ Var7 vz7 vs → vz7

vs7 : ∀{Γ B A} → Var7 Γ A → Var7 (snoc7 Γ B) A; vs7
 = λ x Var7 vz7 vs7 → vs7 (x Var7 vz7 vs7)

Tm7 : Con7 → Ty7 → Set; Tm7
 = λ Γ A →
   (Tm7  : Con7 → Ty7 → Set)
   (var   : ∀{Γ A} → Var7 Γ A → Tm7 Γ A)
   (lam   : ∀{Γ A B} → Tm7 (snoc7 Γ A) B → Tm7 Γ (arr7 A B))
   (app   : ∀{Γ A B} → Tm7 Γ (arr7 A B) → Tm7 Γ A → Tm7 Γ B)
   (tt    : ∀{Γ} → Tm7 Γ top7)
   (pair  : ∀{Γ A B} → Tm7 Γ A → Tm7 Γ B → Tm7 Γ (prod7 A B))
   (fst   : ∀{Γ A B} → Tm7 Γ (prod7 A B) → Tm7 Γ A)
   (snd   : ∀{Γ A B} → Tm7 Γ (prod7 A B) → Tm7 Γ B)
   (left  : ∀{Γ A B} → Tm7 Γ A → Tm7 Γ (sum7 A B))
   (right : ∀{Γ A B} → Tm7 Γ B → Tm7 Γ (sum7 A B))
   (case  : ∀{Γ A B C} → Tm7 Γ (sum7 A B) → Tm7 Γ (arr7 A C) → Tm7 Γ (arr7 B C) → Tm7 Γ C)
   (zero  : ∀{Γ} → Tm7 Γ nat7)
   (suc   : ∀{Γ} → Tm7 Γ nat7 → Tm7 Γ nat7)
   (rec   : ∀{Γ A} → Tm7 Γ nat7 → Tm7 Γ (arr7 nat7 (arr7 A A)) → Tm7 Γ A → Tm7 Γ A)
 → Tm7 Γ A

var7 : ∀{Γ A} → Var7 Γ A → Tm7 Γ A; var7
 = λ x Tm7 var7 lam app tt pair fst snd left right case zero suc rec →
     var7 x

lam7 : ∀{Γ A B} → Tm7 (snoc7 Γ A) B → Tm7 Γ (arr7 A B); lam7
 = λ t Tm7 var7 lam7 app tt pair fst snd left right case zero suc rec →
     lam7 (t Tm7 var7 lam7 app tt pair fst snd left right case zero suc rec)

app7 : ∀{Γ A B} → Tm7 Γ (arr7 A B) → Tm7 Γ A → Tm7 Γ B; app7
 = λ t u Tm7 var7 lam7 app7 tt pair fst snd left right case zero suc rec →
     app7 (t Tm7 var7 lam7 app7 tt pair fst snd left right case zero suc rec)
         (u Tm7 var7 lam7 app7 tt pair fst snd left right case zero suc rec)

tt7 : ∀{Γ} → Tm7 Γ top7; tt7
 = λ Tm7 var7 lam7 app7 tt7 pair fst snd left right case zero suc rec → tt7

pair7 : ∀{Γ A B} → Tm7 Γ A → Tm7 Γ B → Tm7 Γ (prod7 A B); pair7
 = λ t u Tm7 var7 lam7 app7 tt7 pair7 fst snd left right case zero suc rec →
     pair7 (t Tm7 var7 lam7 app7 tt7 pair7 fst snd left right case zero suc rec)
          (u Tm7 var7 lam7 app7 tt7 pair7 fst snd left right case zero suc rec)

fst7 : ∀{Γ A B} → Tm7 Γ (prod7 A B) → Tm7 Γ A; fst7
 = λ t Tm7 var7 lam7 app7 tt7 pair7 fst7 snd left right case zero suc rec →
     fst7 (t Tm7 var7 lam7 app7 tt7 pair7 fst7 snd left right case zero suc rec)

snd7 : ∀{Γ A B} → Tm7 Γ (prod7 A B) → Tm7 Γ B; snd7
 = λ t Tm7 var7 lam7 app7 tt7 pair7 fst7 snd7 left right case zero suc rec →
     snd7 (t Tm7 var7 lam7 app7 tt7 pair7 fst7 snd7 left right case zero suc rec)

left7 : ∀{Γ A B} → Tm7 Γ A → Tm7 Γ (sum7 A B); left7
 = λ t Tm7 var7 lam7 app7 tt7 pair7 fst7 snd7 left7 right case zero suc rec →
     left7 (t Tm7 var7 lam7 app7 tt7 pair7 fst7 snd7 left7 right case zero suc rec)

right7 : ∀{Γ A B} → Tm7 Γ B → Tm7 Γ (sum7 A B); right7
 = λ t Tm7 var7 lam7 app7 tt7 pair7 fst7 snd7 left7 right7 case zero suc rec →
     right7 (t Tm7 var7 lam7 app7 tt7 pair7 fst7 snd7 left7 right7 case zero suc rec)

case7 : ∀{Γ A B C} → Tm7 Γ (sum7 A B) → Tm7 Γ (arr7 A C) → Tm7 Γ (arr7 B C) → Tm7 Γ C; case7
 = λ t u v Tm7 var7 lam7 app7 tt7 pair7 fst7 snd7 left7 right7 case7 zero suc rec →
     case7 (t Tm7 var7 lam7 app7 tt7 pair7 fst7 snd7 left7 right7 case7 zero suc rec)
           (u Tm7 var7 lam7 app7 tt7 pair7 fst7 snd7 left7 right7 case7 zero suc rec)
           (v Tm7 var7 lam7 app7 tt7 pair7 fst7 snd7 left7 right7 case7 zero suc rec)

zero7  : ∀{Γ} → Tm7 Γ nat7; zero7
 = λ Tm7 var7 lam7 app7 tt7 pair7 fst7 snd7 left7 right7 case7 zero7 suc rec → zero7

suc7 : ∀{Γ} → Tm7 Γ nat7 → Tm7 Γ nat7; suc7
 = λ t Tm7 var7 lam7 app7 tt7 pair7 fst7 snd7 left7 right7 case7 zero7 suc7 rec →
   suc7 (t Tm7 var7 lam7 app7 tt7 pair7 fst7 snd7 left7 right7 case7 zero7 suc7 rec)

rec7 : ∀{Γ A} → Tm7 Γ nat7 → Tm7 Γ (arr7 nat7 (arr7 A A)) → Tm7 Γ A → Tm7 Γ A; rec7
 = λ t u v Tm7 var7 lam7 app7 tt7 pair7 fst7 snd7 left7 right7 case7 zero7 suc7 rec7 →
     rec7 (t Tm7 var7 lam7 app7 tt7 pair7 fst7 snd7 left7 right7 case7 zero7 suc7 rec7)
         (u Tm7 var7 lam7 app7 tt7 pair7 fst7 snd7 left7 right7 case7 zero7 suc7 rec7)
         (v Tm7 var7 lam7 app7 tt7 pair7 fst7 snd7 left7 right7 case7 zero7 suc7 rec7)

v07 : ∀{Γ A} → Tm7 (snoc7 Γ A) A; v07
 = var7 vz7

v17 : ∀{Γ A B} → Tm7 (snoc7 (snoc7 Γ A) B) A; v17
 = var7 (vs7 vz7)

v27 : ∀{Γ A B C} → Tm7 (snoc7 (snoc7 (snoc7 Γ A) B) C) A; v27
 = var7 (vs7 (vs7 vz7))

v37 : ∀{Γ A B C D} → Tm7 (snoc7 (snoc7 (snoc7 (snoc7 Γ A) B) C) D) A; v37
 = var7 (vs7 (vs7 (vs7 vz7)))

tbool7 : Ty7; tbool7
 = sum7 top7 top7

true7 : ∀{Γ} → Tm7 Γ tbool7; true7
 = left7 tt7

tfalse7 : ∀{Γ} → Tm7 Γ tbool7; tfalse7
 = right7 tt7

ifthenelse7 : ∀{Γ A} → Tm7 Γ (arr7 tbool7 (arr7 A (arr7 A A))); ifthenelse7
 = lam7 (lam7 (lam7 (case7 v27 (lam7 v27) (lam7 v17))))

times47 : ∀{Γ A} → Tm7 Γ (arr7 (arr7 A A) (arr7 A A)); times47
  = lam7 (lam7 (app7 v17 (app7 v17 (app7 v17 (app7 v17 v07)))))

add7 : ∀{Γ} → Tm7 Γ (arr7 nat7 (arr7 nat7 nat7)); add7
 = lam7 (rec7 v07
       (lam7 (lam7 (lam7 (suc7 (app7 v17 v07)))))
       (lam7 v07))

mul7 : ∀{Γ} → Tm7 Γ (arr7 nat7 (arr7 nat7 nat7)); mul7
 = lam7 (rec7 v07
       (lam7 (lam7 (lam7 (app7 (app7 add7 (app7 v17 v07)) v07))))
       (lam7 zero7))

fact7 : ∀{Γ} → Tm7 Γ (arr7 nat7 nat7); fact7
 = lam7 (rec7 v07 (lam7 (lam7 (app7 (app7 mul7 (suc7 v17)) v07)))
        (suc7 zero7))
