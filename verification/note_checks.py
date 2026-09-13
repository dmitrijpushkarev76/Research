"""
Symbolic checks for "Linearity Does Not Immunise".

Rule adopted after the previous version of this file failed its own audit:
EVERY predicate below must be capable of failing. No literal `True`. No check
whose label names an object the code never constructs. The two checks that
violated this (a "tent map" that only ever differentiated 2*x, and a predicate
that was the constant True) are deleted rather than repaired, because the
claims they were attached to are not claims this note makes.

Run:  python3 note_checks.py      (needs sympy)
Exits non-zero on any failure.
"""
import sympy as sp

results = []


def check(name, ok, detail=""):
    results.append((name, bool(ok), detail))


def audit_own_source():
    """The defect that sank the previous version of this file was a check whose
    predicate was the literal `True`, and another whose label named an object
    (the tent map) the code never built. A value-level guard cannot catch the
    first, because a genuine computation may legitimately evaluate to True. So
    audit the SOURCE: no check's predicate may be a literal constant."""
    import ast
    tree = ast.parse(open(__file__).read())
    bad = []
    n = 0
    for node in ast.walk(tree):
        if isinstance(node, ast.Call) and getattr(node.func, "id", None) == "check":
            n += 1
            pred = node.args[1]
            if isinstance(pred, ast.Constant):
                bad.append((node.lineno, ast.unparse(pred)))
    return n, bad


t, T, g = sp.symbols('t T g', real=True)
r = sp.Symbol('r', nonnegative=True)
u = sp.Symbol('u', positive=True)
x, x0, m = sp.symbols('x x0 m', positive=True)

# ========================================================== 1. Norton's dome
h = sp.Rational(2, 3) / g * r**sp.Rational(3, 2)
tangential = sp.simplify(g * sp.diff(h, r))
check("dome: g*dh/dr = sqrt(r), so the equation of motion is r'' = sqrt(r)",
      sp.simplify(tangential - sp.sqrt(r)) == 0, f"g*dh/dr = {tangential}")

r_of_u = u**4 / 144
check("dome: r = (t-T)^4/144 satisfies r'' = +sqrt(r)  [sign, not squares]",
      sp.simplify(sp.diff(r_of_u, u, 2) - sp.sqrt(r_of_u)) == 0,
      f"r'' = {sp.simplify(sp.diff(r_of_u, u, 2))}, sqrt(r) = {sp.simplify(sp.sqrt(r_of_u))}")

rT = (t - T)**4 / 144
derivs = [sp.simplify(sp.diff(rT, t, k).subs(t, T)) for k in range(5)]
check("dome: the join with the rest solution at t=T is exactly C^3",
      derivs[:4] == [0, 0, 0, 0] and derivs[4] != 0,
      f"d^k r/dt^k at T, k=0..4: {derivs} -- first nonzero at k=4")

check("dome: sqrt is not Lipschitz at 0, which is what permits the bifurcation",
      sp.limit(sp.sqrt(r) / r, r, 0, '+') == sp.oo,
      f"lim_(r->0+) sqrt(r)/r = {sp.limit(sp.sqrt(r)/r, r, 0, '+')}")

# ================================= 2. blow-up: total vs maximal conventions
y = sp.Function('y')
sol = sp.dsolve(sp.Eq(y(t).diff(t), y(t)**2), y(t), ics={y(0): 1})
check("blow-up: x'=x^2, x(0)=1 has solution 1/(1-t)",
      sp.simplify(sol.rhs - 1 / (1 - t)) == 0, f"solution: {sol.rhs}")
check("blow-up: it diverges at t=1, so no solution is defined on all of R",
      sp.limit(sol.rhs, t, 1, '-') == sp.oo)
check("blow-up: but it IS defined on all of (-inf, 1) -- so the MAXIMAL "
      "solution exists and is unique where the TOTAL one does not exist",
      sp.limit(sol.rhs, t, -sp.oo) == 0
      and sol.rhs.subs(t, sp.Rational(999, 1000)) == 1000,
      "which of the two you count is a convention, not a discovery")

# ====================== 3. non-uniqueness without Lipschitz (forward failure)
tp = sp.Symbol('tp', positive=True)
x1 = (tp / 3)**3
check("x'=x^(2/3): x=(t/3)^3 solves it and shares the datum x(0)=0 with x=0",
      sp.simplify(sp.diff(x1, tp) - x1**sp.Rational(2, 3)) == 0
      and sp.simplify(((t / 3)**3).subs(t, 0)) == 0)

# =============== 4. forward uniqueness is not two-directional determinism
# x' = -x^(1/3). Parametrised by the gap w = T* - t > 0 so SymPy can reduce
# (a^(3/2))^(1/3); with x a function of w, x' = -x^(1/3) becomes dx/dw = x^(1/3).
w = sp.Symbol('w', positive=True)
xb = (sp.Rational(2, 3) * w)**sp.Rational(3, 2)
check("x'=-x^(1/3): x = ((2/3)(T*-t))^(3/2) is a solution for t < T*",
      sp.simplify(sp.diff(xb, w) - xb**sp.Rational(1, 3)) == 0,
      f"dx/dw = {sp.simplify(sp.diff(xb, w))} = x^(1/3)")
check("x'=-x^(1/3): it meets the zero solution at T* with matching slope",
      sp.limit(xb, w, 0, '+') == 0 and sp.limit(sp.diff(xb, w), w, 0, '+') == 0)
check("x'=-x^(1/3): and differs from it before T*, so agreement at an instant "
      "does NOT force agreement at all instants -- forward-unique, not deterministic",
      sp.simplify(xb.subs(w, 1)) > 0,
      f"x at gap 1 = {sp.simplify(xb.subs(w, 1))} > 0, while x == 0 after T*")

# ============ 5. the classical side of the self-adjointness correspondence
# V(x) = -x^n at energy 0: (1/2) m x'^2 = x^n, so x' = x^(n/2) sqrt(2/m) and the
# time to reach infinity from x0 is  sqrt(m/2) * int_{x0}^inf x^(-n/2) dx.
# That integral converges iff n/2 > 1, i.e. iff n > 2. This is the classical
# threshold that the Weyl limit-point/limit-circle criterion mirrors.
escape = {}
for n in [1, 2, 3, 4, 6]:
    I = sp.integrate(x**sp.Rational(-n, 2), (x, x0, sp.oo))
    escape[n] = sp.simplify(sp.sqrt(m / 2) * I) if I.is_finite is not False else sp.oo
    if I.has(sp.oo) or I == sp.oo:
        escape[n] = sp.oo

finite = {n: (v != sp.oo and not v.has(sp.oo)) for n, v in escape.items()}
check("V=-x^n: the classical escape time to infinity is finite exactly when n>2",
      finite == {1: False, 2: False, 3: True, 4: True, 6: True},
      f"finite escape? {finite}")

check("V=-x^4 specifically: escape time from x0 is sqrt(m/2)/x0, which is finite",
      sp.simplify(escape[4] - sp.sqrt(m / 2) / x0) == 0,
      f"escape time = {escape[4]}")

check("V=-x^2 (the harmonic threshold): the escape time DIVERGES, so the "
      "classical particle never reaches infinity -- the threshold is sharp",
      escape[2] == sp.oo, f"escape time at n=2 = {escape[2]}")

# ===================================================================== report
print(f"{'RESULT':8}  CLAIM")
print("-" * 78)
ok_all = True
for name, ok, detail in results:
    ok_all &= ok
    print(f"{'PASS' if ok else 'FAIL':8}  {name}")
    if detail:
        print(f"{'':8}  -> {detail}")
print("-" * 78)
n_checks, bad = audit_own_source()
if bad:
    for lineno, src in bad:
        print(f"AUDIT    line {lineno}: predicate is the literal `{src}` -- not a check")
    ok_all = False
else:
    print(f"AUDIT    {n_checks} check() calls; no predicate is a literal constant")
print("-" * 78)
n_ok = sum(o for _, o, _ in results)
print(("ALL CHECKS PASSED" if ok_all else "SOME CHECKS FAILED")
      + f"  ({n_ok}/{len(results)})")
raise SystemExit(0 if ok_all else 1)
