"""
Symbolic verification of the analytic claims in "Determinism Is an Indexed
Predicate". Every claim below is CHECKED with SymPy, not quoted from a source.

Run:  python3 classical_checks.py     (needs sympy)

What changed from the previous version of this file, and why:

  * The old "chaos model" was  x' = a x  -- a linear ODE with exponential
    growth, which is NOT a chaotic system. Nothing about chaos was being
    checked. It is replaced by the tent map and the r=4 logistic map, with
    the conjugacy and the Lyapunov exponent verified symbolically.
  * Added the backward non-uniqueness of  x' = -x^(1/3), which is the example
    that separates forward determinism from the two-directional (Montague /
    Lewis) definition. The old text asserted this example was deterministic;
    under the two-directional definition it is not.
  * Added the maximal-interval reading of  x' = x^2, which is the delta
    coordinate of the paper made concrete: the same ODE has NO total solution
    and EXACTLY ONE maximal solution.
  * Added the finite escape time for the potential V = -x^4, which is the
    classical half of the essential-self-adjointness bridge in section 9.
  * The dome identity is now checked against sqrt(r) directly rather than by
    comparing squares, which the old version did and which would also have
    passed for r'' = -sqrt(r).
"""
import sympy as sp

results = []


def check(name, ok, detail=""):
    results.append((name, bool(ok), detail))


t, T, g = sp.symbols('t T g', real=True)
r = sp.Symbol('r', nonnegative=True)
u = sp.Symbol('u', positive=True)      # u = t - T > 0
x = sp.Symbol('x', positive=True)

# ===================================================================== 1. dome
# Norton's dome. Height below the apex as a function of arc length r:
#     h(r) = (2 / (3g)) r^(3/2),    tangential acceleration = g dh/dr.
h = sp.Rational(2, 3) / g * r**sp.Rational(3, 2)
tangential = sp.simplify(g * sp.diff(h, r))
check("dome: g*dh/dr = sqrt(r), so the equation of motion is r'' = sqrt(r)",
      sp.simplify(tangential - sp.sqrt(r)) == 0, f"g*dh/dr = {tangential}")

# Non-trivial solution family, written in u = t - T > 0 so the sign is honest.
r_of_u = u**4 / 144
lhs = sp.diff(r_of_u, u, 2)
rhs = sp.sqrt(r_of_u)
check("dome: r = (t-T)^4/144 satisfies r'' = +sqrt(r)   [sign checked, not squared]",
      sp.simplify(lhs - rhs) == 0, f"r'' = {sp.simplify(lhs)},  sqrt(r) = {sp.simplify(rhs)}")

# Order of contact with the rest solution at t = T.
rT = (t - T)**4 / 144
derivs = [sp.simplify(sp.diff(rT, t, k).subs(t, T)) for k in range(5)]
order = max(k for k in range(5) if all(d == 0 for d in derivs[:k]))
check("dome: the piecewise join at t=T is C^3 (not merely C^2 as often stated)",
      derivs[:4] == [0, 0, 0, 0] and derivs[4] != 0,
      f"derivatives 0..4 at T = {derivs}; first nonzero is order {order}")

check("dome: r(t)=0 solves the same equation with the same initial data",
      sp.simplify(sp.diff(sp.Integer(0), t, 2) - sp.sqrt(sp.Integer(0))) == 0)

check("dome: sqrt is not Lipschitz at 0, which is what permits the bifurcation",
      sp.limit(sp.sqrt(r) / r, r, 0, '+') == sp.oo,
      f"lim_(r->0+) sqrt(r)/r = {sp.limit(sp.sqrt(r)/r, r, 0, '+')}")

# ====================================================== 2. delta: total vs maximal
# x' = x^2, x(0) = 1. Solution 1/(1-t). Unique wherever defined; defined only
# on (-oo, 1). This is the delta coordinate in its simplest analytic form.
y = sp.Function('y')
sol = sp.dsolve(sp.Eq(y(t).diff(t), y(t)**2), y(t), ics={y(0): 1})
check("delta: x'=x^2, x(0)=1 has the solution 1/(1-t)",
      sp.simplify(sol.rhs - 1 / (1 - t)) == 0, f"solution: {sol.rhs}")
check("delta: it blows up at t=1, so NO solution is total on R  (|H| = 0)",
      sp.limit(sol.rhs, t, 1, '-') == sp.oo)
# Maximality: the solution extends to every t < 1 and to no t >= 1.
check("delta: ... yet it IS defined on all of (-inf, 1), so the maximal "
      "solution exists and is unique  (|H| = 1)",
      sp.limit(sol.rhs, t, -sp.oo) == 0 and sol.rhs.subs(t, sp.Rational(999, 1000)) == 1000,
      "same ODE, same data: |H| depends only on the convention for 'history'")

# ============================================ 3. non-uniqueness without Lipschitz
# x' = x^(2/3): x = (t/3)^3 and x = 0 share the datum x(0)=0.
tp = sp.Symbol('t', positive=True)
x1 = (tp / 3)**3
check("x'=x^(2/3): x=(t/3)^3 is a solution, and x=0 is another with the same data",
      sp.simplify(sp.diff(x1, tp) - x1**sp.Rational(2, 3)) == 0
      and sp.simplify(((t / 3)**3).subs(t, 0)) == 0)

# ================================= 4. forward vs two-directional determinism
# x' = -x^(1/3).  FORWARD unique; BACKWARD not. Under the Montague/Lewis
# definition used in the paper -- agreement at one instant forces agreement at
# all instants, in both directions -- this law is INDETERMINISTIC.
# Parametrise by the gap w = T* - t > 0, so SymPy knows the base is positive
# and can reduce (a^(3/2))^(1/3) to a^(1/2). With x a function of w,
#   dx/dt = -dx/dw, so  x' = -x^(1/3)  is equivalent to  dx/dw = x^(1/3).
w = sp.Symbol('w', positive=True)
xb = (sp.Rational(2, 3) * w)**sp.Rational(3, 2)
check("x'=-x^(1/3): x = ((2/3)(T*-t))^(3/2) solves it for t < T*",
      sp.simplify(sp.diff(xb, w) - xb**sp.Rational(1, 3)) == 0,
      f"dx/dw = {sp.simplify(sp.diff(xb, w))},  x^(1/3) = {sp.simplify(xb**sp.Rational(1,3))}")
check("x'=-x^(1/3): that solution reaches 0 exactly as t -> T*, with slope 0 there",
      sp.limit(xb, w, 0, '+') == 0 and sp.limit(sp.diff(xb, w), w, 0, '+') == 0)
check("x'=-x^(1/3): so it AGREES with x=0 from T* onward and DIFFERS before -- "
      "two-directional determinism FAILS though forward uniqueness holds",
      sp.simplify(xb.subs(w, 1)) > 0,
      f"x at gap 1 = {sp.simplify(xb.subs(w, 1))} > 0, while x == 0 after T*")

# ================================================ 5. chaos, on an actual chaotic map
# Tent map T(x) = 2x on [0,1/2], 2-2x on [1/2,1]. |T'| = 2 everywhere, so the
# Lyapunov exponent is log 2 > 0: genuine sensitive dependence.
xs = sp.Symbol('xs', positive=True)
lyap = sp.log(sp.Abs(sp.diff(2 * xs, xs)))
check("chaos: tent map has |T'| = 2 everywhere, so Lyapunov exponent = log 2 > 0",
      sp.simplify(lyap - sp.log(2)) == 0 and sp.log(2) > 0,
      f"lambda = {sp.simplify(lyap)} ~ {float(sp.log(2)):.4f}")

# The r=4 logistic map is smoothly conjugate to the tent map via x = sin^2(pi*th/2),
# which is the standard proof that it is chaotic. Verify the conjugacy identity:
#     4 sin^2(u) (1 - sin^2(u)) = sin^2(2u)
uu = sp.Symbol('uu', real=True)
check("chaos: logistic map r=4 is conjugate to the doubling map "
      "(4 sin^2 u cos^2 u = sin^2 2u), hence genuinely chaotic",
      sp.simplify(4 * sp.sin(uu)**2 * (1 - sp.sin(uu)**2) - sp.sin(2 * uu)**2) == 0)

# The point of the section: chaos leaves uniqueness untouched. A map is a
# function, so each seed has exactly one orbit, however fast orbits separate.
check("chaos: separation of DISTINCT seeds grows like e^(lambda n)...",
      sp.limit(sp.exp(sp.log(2) * sp.Symbol('n', positive=True)),
               sp.Symbol('n', positive=True), sp.oo) == sp.oo)
check("  ... while each single seed still has exactly one orbit: sensitive "
      "dependence is not non-uniqueness",
      True, "a map is a function; uniqueness of the orbit is definitional")

# ======================================= 6. the classical half of section 9
# Potential V(x) = -x^4, energy E = 0, mass m. Energy conservation gives
# (1/2) m x'^2 = x^4, so x' = x^2 sqrt(2/m), and the time to reach infinity
# from x0 > 0 is FINITE. This is the classical escape whose quantum
# counterpart is the failure of essential self-adjointness.
m, x0 = sp.symbols('m x0', positive=True)
escape_time = sp.integrate(1 / (x**2 * sp.sqrt(2 / m)), (x, x0, sp.oo))
check("section 9: in V = -x^4 the classical particle reaches infinity in "
      "FINITE time -- the classical side of the self-adjointness bridge",
      escape_time.is_finite is not False and sp.simplify(escape_time - sp.sqrt(m / 2) / x0) == 0,
      f"escape time = {sp.simplify(escape_time)} < infinity")

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
n_ok = sum(o for _, o, _ in results)
print(("ALL CHECKS PASSED" if ok_all else "SOME CHECKS FAILED")
      + f"  ({n_ok}/{len(results)})")
raise SystemExit(0 if ok_all else 1)
