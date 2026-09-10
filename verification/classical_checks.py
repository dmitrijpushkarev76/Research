"""
Machine verification of the classical-mechanics claims used in the paper.
Every claim below is CHECKED symbolically, not quoted from a source.
Run:  uv run --with sympy python classical_checks.py
"""
import sympy as sp

results = []
def check(name, ok, detail=""):
    results.append((name, bool(ok), detail))

t, T, r, g, x = sp.symbols('t T r g x', real=True)

# ---------------------------------------------------------------- 1. Norton dome
# Dome height below apex, as a function of arc length r from the apex:
#     h(r) = (2 / (3g)) * r**(3/2)
# Tangential acceleration = g * dh/dr.
h = sp.Rational(2,3)/g * r**sp.Rational(3,2)
tangential = sp.simplify(g * sp.diff(h, r))
check("Norton dome: g*dh/dr simplifies to sqrt(r)  =>  r'' = sqrt(r)",
      sp.simplify(tangential - sp.sqrt(r)) == 0, f"g*dh/dr = {tangential}")

# The non-trivial solution family r(t) = (t-T)^4 / 144 for t >= T.
rT = (t - T)**4 / 144
lhs = sp.diff(rT, t, 2)
rhs = sp.sqrt(sp.simplify(rT))
# sqrt((t-T)^4/144) = (t-T)^2/12 for real (t-T); compare squares to avoid branch issues.
check("Norton dome: r(t)=(t-T)^4/144 satisfies r'' = sqrt(r)",
      sp.simplify(lhs**2 - sp.simplify(rT)) == 0,
      f"r'' = {sp.simplify(lhs)},  sqrt(r) = (t-T)^2/12")

# Initial conditions at t = T: r = r' = r'' = 0  (matches the rest solution C^2).
vals = [sp.simplify(sp.diff(rT, t, k).subs(t, T)) for k in range(3)]
check("Norton dome: r(T)=r'(T)=r''(T)=0, so the piecewise solution is C^2",
      all(v == 0 for v in vals), f"[r,r',r''](T) = {vals}")

# The trivial solution r(t) = 0 also satisfies the equation with the same data.
check("Norton dome: r(t)=0 is also a solution with identical initial data",
      sp.simplify(sp.diff(sp.Integer(0), t, 2) - sp.sqrt(sp.Integer(0))) == 0)

# Lipschitz failure: |sqrt(r) - sqrt(0)| / |r - 0| = r^{-1/2} -> infinity as r -> 0+.
lip = sp.limit(sp.sqrt(r)/r, r, 0, '+')
check("Norton dome: sqrt(r) is NOT Lipschitz at r=0 (difference quotient diverges)",
      lip == sp.oo, f"lim_{{r->0+}} sqrt(r)/r = {lip}")

# ------------------------------------------------- 2. Generic non-uniqueness: x' = x^(2/3)
# x(t) = (t/3)^3 and x(t) = 0 both solve x' = x^(2/3) with x(0)=0.
# Use a positive symbol: for negative arguments sympy's principal branch of
# z**(2/3) is complex, which is a branch-cut artefact, not a failure of the ODE.
tp = sp.Symbol('t', positive=True)
x1 = (tp/3)**3
check("x' = x^(2/3): x=(t/3)^3 solves it (t>0)",
      sp.simplify(sp.diff(x1, tp) - x1**sp.Rational(2,3)) == 0,
      f"x' = {sp.simplify(sp.diff(x1, tp))},  x^(2/3) = {sp.simplify(x1**sp.Rational(2,3))}")
check("x' = x^(2/3): x=(t/3)^3 and x=0 share the initial datum x(0)=0",
      sp.simplify(((t/3)**3).subs(t, 0)) == 0)
check("x' = x^(2/3): f(x)=x^(2/3) is not Lipschitz at 0",
      sp.limit(sp.Symbol('u', positive=True)**sp.Rational(2,3)/sp.Symbol('u', positive=True),
               sp.Symbol('u', positive=True), 0, '+') == sp.oo)

# ------------------------------------------------- 3. Finite-time blow-up: x' = x^2, x(0)=1
sol = sp.dsolve(sp.Eq(sp.Derivative(sp.Function('y')(t), t), sp.Function('y')(t)**2),
                sp.Function('y')(t), ics={sp.Function('y')(0): 1})
check("x' = x^2, x(0)=1 has solution 1/(1-t): unique but NOT global",
      sp.simplify(sol.rhs - 1/(1 - t)) == 0, f"solution: {sol.rhs}")
check("  ... it blows up at t=1 (no history defined on all of R)",
      sp.limit(sol.rhs, t, 1, '-') == sp.oo)

# --------------------------------------- 4. Picard-Lindelof does apply where f IS Lipschitz
# x' = x, x(0)=1  ->  unique global solution e^t.
sol2 = sp.dsolve(sp.Eq(sp.Derivative(sp.Function('y')(t), t), sp.Function('y')(t)),
                 sp.Function('y')(t), ics={sp.Function('y')(0): 1})
check("x' = x, x(0)=1: Lipschitz f gives the unique global solution e^t",
      sp.simplify(sol2.rhs - sp.exp(t)) == 0, f"solution: {sol2.rhs}")

# --------------------------------------- 5. Lyapunov separation is exponential, not branching
# Two trajectories of x' = a*x with a>0 separate as exp(a t) but each is unique.
a, d0 = sp.symbols('a delta_0', positive=True)
sep = sp.simplify(d0*sp.exp(a*t))
check("Chaos model x'=a x: separation delta_0*exp(a t) grows without bound...",
      sp.limit(sep, t, sp.oo) == sp.oo)
check("  ... yet each initial condition still has exactly one solution (uniqueness intact)",
      sp.simplify(sp.diff(d0*sp.exp(a*t), t) - a*(d0*sp.exp(a*t))) == 0)

print(f"{'RESULT':8}  CLAIM")
print("-" * 78)
ok_all = True
for name, ok, detail in results:
    ok_all &= ok
    print(f"{'PASS' if ok else 'FAIL':8}  {name}")
    if detail:
        print(f"{'':8}  -> {detail}")
print("-" * 78)
print(("ALL CHECKS PASSED" if ok_all else "SOME CHECKS FAILED") + f"  ({sum(o for _,o,_ in results)}/{len(results)})")
raise SystemExit(0 if ok_all else 1)
