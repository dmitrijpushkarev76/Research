"""
Symbolic and numerical checks for "The Global-Maximal Gap".

Every claim in the manuscript that can be mechanically re-derived is
re-derived here.  Rule carried over from the earlier verification file in
this repository: EVERY predicate below must be capable of failing.  No
literal `True`; no check whose label names an object the code never builds.
The final AST audit enforces the first half of that rule on this file's own
source.

These checks are evidence, not proof.  The proofs are in the manuscript and
are analytic; what follows is an independent path to the same values, run so
that an arithmetic slip cannot survive into the text unnoticed.

Run:  python3 gap_checks.py     (needs sympy and mpmath)
Exits non-zero on any failure.
"""
import sympy as sp
import mpmath as mp

results = []


def check(name, ok, detail=""):
    results.append((name, bool(ok), detail))


def audit_own_source():
    """A value-level guard cannot catch a predicate that is the literal
    `True`, because a genuine computation may legitimately evaluate to True.
    So audit the SOURCE: no check's predicate may be a literal constant."""
    import ast
    tree = ast.parse(open(__file__).read())
    bad, n = [], 0
    for node in ast.walk(tree):
        if isinstance(node, ast.Call) and getattr(node.func, "id", None) == "check":
            n += 1
            pred = node.args[1]
            if isinstance(pred, ast.Constant):
                bad.append((node.lineno, ast.unparse(pred)))
    return n, bad


mp.mp.dps = 40
# Both integrands have an algebraic endpoint singularity at 0 (x^(-2/3) and
# x^(-3/4)).  Plain mp.quad on [0,1,inf] loses ~10 digits there, so every
# numerical path below splits near the singularity; the tolerances state what
# the split quadrature actually achieves, not what would look impressive.
SPLIT_W = [0, mp.mpf('1e-8'), mp.mpf('1e-4'), mp.mpf('0.01'), 1, 10, mp.inf]
SPLIT_M = [0, mp.mpf('1e-8'), mp.mpf('1e-3'), 1, 10, mp.inf]
u = sp.Symbol('u', positive=True)
x = sp.Symbol('x', positive=True)
r = sp.Symbol('r', positive=True)
s = sp.Symbol('s', real=True)
t, T, g = sp.symbols('t T g', real=True)

# =================================================== 1. the witness, sec. 6
f_w = x**sp.Rational(2, 3) + x**2          # f on x > 0; f is even

check("witness: the substitution x = u^3 turns dx/(x^(2/3)+x^2) into 3du/(1+u^4)",
      sp.simplify((1 / f_w).subs(x, u**3) * sp.diff(u**3, u) - 3 / (1 + u**4)) == 0,
      f"transformed integrand = {sp.simplify((1/f_w).subs(x, u**3) * 3*u**2)}")

I4 = sp.integrate(1 / (1 + u**4), (u, 0, sp.oo))
check("witness: int_0^inf du/(1+u^4) = (pi/4)/sin(pi/4)",
      sp.simplify(I4 - (sp.pi / 4) / sp.sin(sp.pi / 4)) == 0,
      f"sympy gives {sp.simplify(I4)}")

Tstar = sp.simplify(3 * I4)
check("witness: T* = 3*sqrt(2)*pi/4  (the closed form printed in sec. 6)",
      sp.simplify(Tstar - 3 * sp.sqrt(2) * sp.pi / 4) == 0,
      f"T* = {Tstar} = {sp.N(Tstar, 12)}")

check("witness: the manuscript's decimal 3.3321622036 matches T* to 10 places",
      abs(sp.N(Tstar, 25) - sp.Rational(33321622036, 10**10)) < sp.Rational(1, 10**10),
      f"T* = {sp.N(Tstar, 14)}")

# independent numerical path: quadrature on the ORIGINAL integrand, no substitution
T_num = mp.quad(lambda v: 1 / (v**(mp.mpf(2) / 3) + v**2), SPLIT_W)
check("witness: direct quadrature of int_0^inf dx/(x^(2/3)+x^2) agrees with the "
      "closed form to 14 places  [independent of the substitution]",
      abs(T_num - mp.mpf(str(sp.N(Tstar, 40)))) < mp.mpf('1e-14'),
      f"quadrature {mp.nstr(T_num, 15)} vs closed form {sp.N(Tstar, 15)}")

# The manuscript reports, as a sanity check only, that an RK4 integration from
# x = 1e-12 reaches x = 1e7 at t = 3.3319.  Reproduce it, and separately compute
# what that elapsed time must be exactly, namely F(1e7) - F(1e-12).
def _rk4_to(target=1e7, x0=1e-12):
    def fw(z):
        return z**(2.0 / 3.0) + z * z
    z, tt, n = x0, 0.0, 0
    while z < target and n < 10**7:
        hh = min(0.05 * z / fw(z), 1e-3)
        k1 = fw(z); k2 = fw(z + hh * k1 / 2); k3 = fw(z + hh * k2 / 2); k4 = fw(z + hh * k3)
        z += hh * (k1 + 2 * k2 + 2 * k3 + k4) / 6
        tt += hh; n += 1
    return z, tt, n


_x_end, t_rk4, n_rk4 = _rk4_to()
t_exact = mp.quad(lambda z: 1 / (z**(mp.mpf(2) / 3) + z**2),
                  [mp.mpf('1e-12'), mp.mpf('1e-6'), 1, 100, mp.mpf('1e7')])
check("sec. 6 sanity check: RK4 from x = 1e-12 to x = 1e7 agrees with the exact "
      "elapsed time F(1e7) - F(1e-12) to 7 places, and rounds to the reported 3.3319",
      abs(t_rk4 - float(t_exact)) < 1e-7 and f"{t_rk4:.4f}" == "3.3319",
      f"RK4 t = {t_rk4:.10f} in {n_rk4} steps; exact = {mp.nstr(t_exact, 12)}")

check("sec. 6: that elapsed time falls short of T* by the head and tail the "
      "truncation omits -- 3*(1e-12)^(1/3) = 3e-4 plus int_(1e7)^inf x^-2 dx = 1e-7",
      abs((mp.mpf(str(sp.N(Tstar, 40))) - t_exact)
          - (3 * mp.mpf('1e-12')**(mp.mpf(1) / 3) + mp.mpf('1e-7'))) < mp.mpf('1e-8'),
      f"T* - t = {mp.nstr(mp.mpf(str(sp.N(Tstar, 40))) - t_exact, 8)}, "
      f"predicted head+tail = {mp.nstr(3*mp.mpf('1e-12')**(mp.mpf(1)/3) + mp.mpf('1e-7'), 8)}")

check("witness: f is NOT locally Lipschitz at 0 -- |f(x)-f(0)|/|x| -> +oo",
      sp.limit(f_w / x, x, 0, '+') == sp.oo,
      f"lim_(x->0+) f(x)/x = {sp.limit(f_w/x, x, 0, '+')}")

check("witness: f IS C^1 away from 0, so the failure is located at one point only",
      sp.diff(f_w, x).subs(x, sp.Rational(1, 2)).is_finite
      and sp.limit(sp.diff(f_w, x), x, 0, '+') == sp.oo,
      f"f'(x) = {sp.diff(f_w, x)}, f'(0+) = {sp.limit(sp.diff(f_w, x), x, 0, '+')}")

# Lemma 6(ii): phi = F^{-1} has phi'(0+) = 0, which is what makes x_T C^1 at T.
# F(x) = int_0^x du/f; near 0, f ~ x^(2/3) so F ~ 3x^(1/3), phi ~ (t/3)^3, phi' ~ t^2/9 -> 0.
F_near = sp.integrate(u**sp.Rational(-2, 3), (u, 0, x))
check("Lemma 6(ii) at the witness: F(x) ~ 3x^(1/3) near 0, so phi(t) ~ (t/3)^3 and "
      "phi'(0+) = 0 -- this is why the join at the departure time is C^1",
      sp.simplify(F_near - 3 * x**sp.Rational(1, 3)) == 0
      and sp.limit(sp.diff((t / 3)**3, t), t, 0, '+') == 0,
      f"int_0^x u^(-2/3) du = {sp.simplify(F_near)}; d/dt (t/3)^3 -> 0 at 0+")

# ============================ 2. Proposition 8: the ratio conditions are weaker
f_a = u / sp.log(1 / u)
check("Prop 8(i) counterexample: f(u) = u/log(1/u) has f(u)/u -> 0 at 0+ "
      "[so it is 'sublinear' in the ratio sense]",
      sp.limit(f_a / u, u, 0, '+') == 0,
      f"lim f(u)/u = {sp.limit(f_a/u, u, 0, '+')}")
Ia = sp.integrate(1 / f_a, (u, 0, sp.Rational(1, 2)))
check("Prop 8(i) counterexample: yet int_0^(1/2) du/f(u) DIVERGES, so (H2) fails -- "
      "the ratio condition does not imply (H2)",
      Ia == sp.oo or Ia.has(sp.oo),
      f"int = {Ia}")

f_b = u * sp.log(u)
check("Prop 8(ii) counterexample: f(u) = u*log(u) has f(u)/u -> +oo at infinity "
      "[so it is 'superlinear' in the ratio sense]",
      sp.limit(f_b / u, u, sp.oo) == sp.oo,
      f"lim f(u)/u = {sp.limit(f_b/u, u, sp.oo)}")
Ib = sp.integrate(1 / f_b, (u, 2, sp.oo))
check("Prop 8(ii) counterexample: yet int_2^inf du/(u log u) DIVERGES, so (H3) fails -- "
      "the ratio condition does not imply (H3)",
      Ib == sp.oo or Ib.has(sp.oo),
      f"int = {Ib}")

# the forward implications of Prop 8, at the level the proof uses them
check("Prop 8(i) forward: if f(u) <= C*u near 0 then int_0 du/f diverges "
      "[witness C=1: int_0^1 du/u]",
      sp.integrate(1 / u, (u, 0, 1)) == sp.oo,
      "int_0^1 du/u = oo, and 1/f >= 1/(Cu) pointwise")

# ======================================= 3. power-law corollary, sec. 5
p = sp.Symbol('p', positive=True)
h2 = {}
for pv in [sp.Rational(1, 3), sp.Rational(2, 3), sp.Integer(1), sp.Rational(3, 2), sp.Integer(2)]:
    I = sp.integrate(u**(-pv), (u, 0, 1))
    h2[pv] = not (I == sp.oo or I.has(sp.oo))
check("Corollary: for f ~ u^p at 0+, (H2) holds exactly for p < 1",
      h2 == {sp.Rational(1, 3): True, sp.Rational(2, 3): True, sp.Integer(1): False,
             sp.Rational(3, 2): False, sp.Integer(2): False},
      f"(H2) by exponent: {[(str(k), v) for k, v in h2.items()]}")

h3 = {}
for qv in [sp.Rational(1, 2), sp.Integer(1), sp.Rational(3, 2), sp.Integer(2), sp.Integer(3)]:
    I = sp.integrate(u**(-qv), (u, 1, sp.oo))
    h3[qv] = not (I == sp.oo or I.has(sp.oo))
check("Corollary: for f ~ u^q at infinity, (H3) holds exactly for q > 1",
      h3 == {sp.Rational(1, 2): False, sp.Integer(1): False, sp.Rational(3, 2): True,
             sp.Integer(2): True, sp.Integer(3): True},
      f"(H3) by exponent: {[(str(k), v) for k, v in h3.items()]}")

check("Sec. 5 caution: p = 2/3 < 1 yet u^(2/3) > u on (0,1) -- 'sublinear' names "
      "the exponent, not the function",
      (sp.Rational(2, 3) < 1)
      and sp.Rational(1, 2)**sp.Rational(2, 3) > sp.Rational(1, 2),
      f"(1/2)^(2/3) = {sp.N(sp.Rational(1,2)**sp.Rational(2,3), 8)} > 0.5")

# ================================ 4. (H4) is not removable, sec. 7
check("(H4) counterexample: for f(x) = |x|^(2/3) on the negative half-line, "
      "int_(-inf)^(-1) dx/f DIVERGES, so S* = oo and the (S,T)=(0,oo) solution is global",
      sp.integrate(u**sp.Rational(-2, 3), (u, 1, sp.oo)) == sp.oo,
      "exponent 2/3 <= 1 at infinity, so (H3)-type convergence fails on that side")

# SymPy's radical solver does not terminate on 1/(y^(2/3)+y^2) directly, and on
# the substituted form it returns an exp_polar expression.  So verify the
# manuscript's own argument instead: the elementary bounds it states in sec. 6,
# cross-checked by quadrature on the UNSUBSTITUTED integrand.
H2_bound = sp.integrate(3, (u, 0, 1))                    # 3/(1+u^4) <= 3 on [0,1]
H2_num = mp.quad(lambda y: 1 / (y**(mp.mpf(2) / 3) + y**2), SPLIT_W[:5])
check("sec. 6 (H2) for the witness: int_0^1 3du/(1+u^4) <= 3 < oo, and quadrature "
      "of the original integrand on (0,1] agrees with that bound",
      H2_bound == 3 and 0 < H2_num < 3,
      f"bound 3; quadrature int_0^1 dx/(x^(2/3)+x^2) = {mp.nstr(H2_num, 12)}")

H3_bound = sp.integrate(3 * u**-4, (u, 1, sp.oo))        # 3/(1+u^4) <= 3u^-4 on [1,oo)
H3_num = mp.quad(lambda y: 1 / (y**(mp.mpf(2) / 3) + y**2), [1, mp.inf])
check("sec. 6 (H3) for the witness: int_1^inf 3u^-4 du = 1 < oo, and quadrature "
      "of the original integrand on [1,oo) agrees with that bound",
      H3_bound == 1 and 0 < H3_num < 1,
      f"bound {H3_bound}; quadrature int_1^inf dx/(x^(2/3)+x^2) = {mp.nstr(H3_num, 12)}")

check("sec. 6 (H4) for the witness: f is even, so int_(-inf)^(-1) dx/f equals the "
      "(H3) integral just bounded -- the reflection is exact, not approximate",
      abs(mp.quad(lambda y: 1 / (abs(-y)**(mp.mpf(2) / 3) + y**2), [1, mp.inf]) - H3_num)
      < mp.mpf('1e-20'),
      f"reflected integral = {mp.nstr(mp.quad(lambda y: 1/(abs(-y)**(mp.mpf(2)/3)+y**2), [1, mp.inf]), 12)}")

check("sec. 6: the two pieces sum to T*, which is the arithmetic the closed form "
      "must satisfy",
      abs((H2_num + H3_num) - mp.mpf(str(sp.N(Tstar, 40)))) < mp.mpf('1e-14'),
      f"{mp.nstr(H2_num, 12)} + {mp.nstr(H3_num, 12)} = {mp.nstr(H2_num + H3_num, 15)}")

# ============================== 5. sec. 8 comparison rows that are computable
r_dome = (t - T)**4 / 144
check("sec. 8 / Norton dome: r = (t-T)^4/144 solves r'' = +sqrt(r)  [C1 holds]",
      sp.simplify(sp.diff(r_dome, t, 2) - sp.sqrt(sp.Abs(r_dome))) == 0,
      f"r'' = {sp.simplify(sp.diff(r_dome, t, 2))}")
check("sec. 8 / Norton dome: that branch is a POLYNOMIAL, hence defined for all t -- "
      "so C2 (bounded maximal interval) FAILS, as the table says",
      sp.Poly(sp.expand(r_dome), t).degree() == 4,
      "a polynomial has no finite-time blow-up")

w = sp.Symbol('w', positive=True)      # w = t - k > 0, the branch after departure
x_e = w**3
V_e = -sp.Rational(9, 2) * sp.Abs(x)**sp.Rational(4, 3)
force = sp.simplify(-sp.diff(-sp.Rational(9, 2) * x**sp.Rational(4, 3), x))
check("sec. 8 / Earman 3.5: V = -(9/2)x^(4/3) gives force = 6*x^(1/3) on x>0",
      sp.simplify(force - 6 * x**sp.Rational(1, 3)) == 0, f"force = {force}")
check("sec. 8 / Earman 3.5: x = (t-k)^3 satisfies x'' = 6*x^(1/3) on the departing "
      "branch, and is a cubic, hence global -- C2 FAILS, as the table says",
      sp.simplify(sp.diff(x_e, w, 2) - 6 * x_e**sp.Rational(1, 3)) == 0
      and sp.Poly(sp.expand(x_e), w).degree() == 3,
      f"x'' = {sp.diff(x_e, w, 2)}, 6 x^(1/3) = {sp.simplify(6*x_e**sp.Rational(1,3))}")
check("sec. 8 / Earman 3.5: the branch is odd in w, so the mirror branch -(t-k)^3 "
      "solves the same equation with the odd force 6*sgn(x)|x|^(1/3) -- both are global",
      sp.simplify(sp.diff(-x_e, w, 2) - (-6) * x_e**sp.Rational(1, 3)) == 0,
      f"(-x)'' = {sp.diff(-x_e, w, 2)}")

# ============================ 6. Proposition 10: the dome no-go, sec. 11.1
check("Prop 10: arc-length parametrisation rho'^2 + z'^2 = 1 forces |z'| <= 1 "
      "[the real solutions of 1 - s^2 >= 0 are exactly [-1,1]]",
      sp.solve_univariate_inequality(1 - s**2 >= 0, s, relational=False)
      == sp.Interval(-1, 1),
      f"{{s : rho'^2 = 1-s^2 >= 0}} = {sp.solve_univariate_inequality(1-s**2>=0, s, relational=False)}")

h_cand = (sp.Rational(2, 3) * r**sp.Rational(3, 2) + sp.Rational(1, 3) * r**3) / g
check("Prop 10: the candidate h(r) = (1/g)(2/3 r^(3/2) + 1/3 r^3) does give "
      "r'' = g h'(r) = sqrt(r) + r^2",
      sp.simplify(g * sp.diff(h_cand, r) - (sp.sqrt(r) + r**2)) == 0,
      f"g h'(r) = {sp.simplify(g*sp.diff(h_cand, r))}")

thr = sp.nsolve(sp.sqrt(r) + r**2 - sp.Rational(98, 10), r, 2.5)
check("Prop 10: with g = 9.8 the candidate violates |h'| <= 1 beyond r ~ 2.85, "
      "so no such surface of revolution exists out to infinity",
      abs(float(thr) - 2.85) < 0.01 and float(thr) > 0,
      f"sqrt(r) + r^2 = 9.8 at r = {float(thr):.6f}")

check("Prop 10: |r''| <= g therefore bounds growth quadratically -- integrating "
      "the bound twice from rest gives r(t) <= r(0) + g t^2/2, which is finite "
      "for every finite t, so r cannot reach +oo in finite time",
      sp.limit(g * t**2 / 2, t, 5).is_finite
      and sp.integrate(sp.integrate(g, (t, 0, t)), (t, 0, t)) == g * t**2 / 2,
      f"double integral of the bound = {sp.integrate(sp.integrate(g, (t,0,t)), (t,0,t))}")

# Prop 10, the angular-momentum caveat added in the audit: derive the centrifugal
# term from the full Lagrangian rather than asserting it.
tt = sp.Symbol('tt', real=True)
m_, pth = sp.symbols('m_ pth', positive=True)
rf = sp.Function('rf', positive=True)(tt)
th = sp.Function('th', real=True)(tt)
rho = sp.Function('rho', positive=True)
hh = sp.Function('hh', real=True)
L_full = (m_ / 2) * (sp.diff(rf, tt)**2 + rho(rf)**2 * sp.diff(th, tt)**2) + m_ * g * hh(rf)

# theta is cyclic: p_theta = dL/d(thetadot) = m rho^2 thetadot is conserved
p_theta = sp.diff(L_full, sp.diff(th, tt))
check("Prop 10 caveat: theta is cyclic, so p_theta = m*rho(r)^2*thetadot is conserved",
      sp.simplify(p_theta - m_ * rho(rf)**2 * sp.diff(th, tt)) == 0
      and sp.simplify(sp.diff(L_full, th)) == 0,
      f"p_theta = {p_theta}; dL/dtheta = {sp.diff(L_full, th)}")

# Euler-Lagrange in r, then eliminate thetadot via p_theta
EL_r = sp.diff(sp.diff(L_full, sp.diff(rf, tt)), tt) - sp.diff(L_full, rf)
rddot = sp.solve(EL_r, sp.diff(rf, tt, 2))[0]
rddot = rddot.subs(sp.diff(th, tt), pth / (m_ * rho(rf)**2))
predicted = g * sp.Derivative(hh(rf), rf).doit() + (pth**2 / m_**2) * sp.diff(rho(rf), rf) / rho(rf)**3
check("Prop 10 caveat: with angular momentum the meridional equation is "
      "r'' = g h'(r) + (p_theta^2/m^2) * rho'(r)/rho(r)^3, NOT r'' = g h'(r)",
      sp.simplify(rddot - predicted) == 0,
      f"r'' = {sp.simplify(rddot)}")

check("Prop 10 caveat: that centrifugal term is unbounded as rho -> 0, so the "
      "|r''| <= g bound genuinely needs the zero-angular-momentum hypothesis",
      sp.limit(1 / sp.Symbol('rr', positive=True)**3, sp.Symbol('rr', positive=True), 0, '+') == sp.oo,
      "rho^-3 -> oo, and no bound in terms of g alone survives")

# (H4a) in the sec. 7 counterexample, and the independence of (H4a) from (H2)
check("sec. 7 counterexample: (H4a) HOLDS for it -- int_(-1)^0 dx/|x|^(2/3) = 3 -- "
      "so it is (H4b) alone that fails, as the corrected text says",
      sp.integrate(u**sp.Rational(-2, 3), (u, 0, 1)) == 3,
      f"int_0^1 v^(-2/3) dv = {sp.integrate(u**sp.Rational(-2,3), (u, 0, 1))}")

check("(H4a) does NOT follow from (H2): f(u) = u^(2/3) for u>0 and f(u) = |u| for "
      "u<0 is continuous, satisfies (H1) and (H2), yet int_(-1)^0 du/f = oo",
      (not sp.integrate(u**sp.Rational(-2, 3), (u, 0, 1)).has(sp.oo))
      and sp.integrate(1 / u, (u, 0, 1)) == sp.oo,
      "(H2) side = 3 < oo; negative side = int_0^1 dv/v = oo")

# ========================= 7. Proposition 11: the potential realisation, 11.2
G = sp.sqrt(sp.Rational(4, 3) * x**sp.Rational(3, 2) + sp.Rational(2, 3) * x**3)
check("Prop 11: G G' = sqrt(x) + x^2, so solutions of x' = G(x) solve x'' = sqrt(x) + x^2",
      sp.simplify(G * sp.diff(G, x) - (sp.sqrt(x) + x**2)) == 0,
      f"G G' = {sp.simplify(G*sp.diff(G, x))}")
check("Prop 11: G(0) = 0 and G > 0 on (0, oo), so (H1) holds on the half-line",
      sp.limit(G, x, 0, '+') == 0 and G.subs(x, 1) > 0,
      f"G(0+) = {sp.limit(G, x, 0, '+')}, G(1) = {sp.simplify(G.subs(x, 1))}")
check("Prop 11: G(x) ~ x^(3/4) as x -> 0+, exponent 3/4 < 1, so (H2) holds",
      sp.simplify(sp.limit(G / x**sp.Rational(3, 4), x, 0, '+')) == sp.sqrt(sp.Rational(4, 3)),
      f"lim G/x^(3/4) = {sp.simplify(sp.limit(G/x**sp.Rational(3,4), x, 0, '+'))} (finite, nonzero)")
check("Prop 11: G(x) ~ x^(3/2) as x -> oo, exponent 3/2 > 1, so (H3) holds",
      sp.simplify(sp.limit(G / x**sp.Rational(3, 2), x, sp.oo)) == sp.sqrt(sp.Rational(2, 3)),
      f"lim G/x^(3/2) = {sp.simplify(sp.limit(G/x**sp.Rational(3,2), x, sp.oo))} (finite, nonzero)")

v = sp.Symbol('v', positive=True)
beta_int = sp.integrate(v**sp.Rational(-5, 6) * (1 + v)**sp.Rational(-1, 2), (v, 0, sp.oo))
check("Prop 11: int_0^inf v^(-5/6)(1+v)^(-1/2) dv = B(1/6, 1/3) EXACTLY "
      "[this is the identity the closed form rests on]",
      sp.simplify(beta_int - sp.beta(sp.Rational(1, 6), sp.Rational(1, 3))) == 0,
      f"sympy: {sp.simplify(beta_int)}")

T_mech_closed = (sp.Rational(2, 3) * sp.sqrt(sp.Rational(3, 2))
                 * 2**sp.Rational(-1, 3) * sp.beta(sp.Rational(1, 6), sp.Rational(1, 3)))
T_mech_num = mp.quad(lambda z: 1 / mp.sqrt(mp.mpf(4) / 3 * z**mp.mpf(1.5)
                                           + mp.mpf(2) / 3 * z**3), SPLIT_M)
check("Prop 11: the closed form (2/3)sqrt(3/2)2^(-1/3)B(1/6,1/3) agrees with direct "
      "quadrature of int_0^inf dx/G(x) to 11 places",
      abs(mp.mpf(str(sp.N(T_mech_closed, 40))) - T_mech_num) < mp.mpf('1e-11'),
      f"closed form {sp.N(T_mech_closed, 16)} vs quadrature {mp.nstr(T_mech_num, 16)}")
check("Prop 11: the manuscript's decimal 5.4521363617 matches to 10 places",
      abs(sp.N(T_mech_closed, 25) - sp.Rational(54521363617, 10**10)) < sp.Rational(1, 10**10),
      f"T*_mech = {sp.N(T_mech_closed, 14)}")

check("Prop 11: T*_mech differs from T* -- the mechanical lifetime is NOT the "
      "witness lifetime, and the manuscript states them separately",
      abs(sp.N(T_mech_closed - Tstar, 20)) > sp.Rational(1, 100),
      f"T*_mech - T* = {sp.N(T_mech_closed - Tstar, 12)}")

# =================================================================== report
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
