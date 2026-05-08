/**
 * Nesab AI — Calculator Library (Node.js port)
 * Ported from Nesab.Ai/tools/calculators.php
 */

function calcPersonalStandard(p) {
  const salary = parseFloat(p.salary || 0);
  const jobStatus = (p.job_status || "حكومي").trim();
  const months = Math.max(1, parseInt(p.months || 60));
  const profitRate = parseFloat(p.profit_rate || 4.9) / 100;
  if (salary <= 0) return { error: "الراتب يجب أن يكون أكبر من صفر." };
  const dedRate = jobStatus === "عسكري" ? 0.25 : 0.3333;
  const installment = salary * dedRate;
  const totalFin = installment * months;
  const approvalAmt = totalFin / (1 + (profitRate * months) / 12);
  const adminFee = Math.min(approvalAmt / 200, 2500);
  const tax = adminFee * 0.15;
  const totalFees = adminFee + tax;
  const bankProfit = (approvalAmt * profitRate * months) / 12;
  const netFinal = approvalAmt - totalFees;
  return {
    max_installment: r(installment), total_financing: r(totalFin), approval_amount: r(approvalAmt),
    admin_fee: r(adminFee), tax_15pct: r(tax), total_fees: r(totalFees), bank_profit: r(bankProfit),
    net_after_fees: r(netFinal), deduction_rate_pct: r(dedRate * 100), months, status: "within_limit",
  };
}

function calcPersonalPlus(p) {
  const salary = parseFloat(p.salary || 0);
  const jobStatus = (p.job_status || "حكومي").trim();
  const hasRE = !!p.has_real_estate;
  const cards1 = parseFloat(p.cards1 || 0);
  const cards2 = parseFloat(p.cards2 || 0);
  const months = Math.max(1, parseInt(p.months || 60));
  const profitRate = parseFloat(p.profit_rate || 4.9) / 100;
  if (salary <= 0) return { error: "الراتب يجب أن يكون أكبر من صفر." };
  let dedRate;
  if (!hasRE) { dedRate = jobStatus === "عسكري" ? 0.25 : 0.3333; }
  else { dedRate = jobStatus === "عسكري" ? 0.55 : salary < 15000 ? 0.55 : 0.65; }
  const installment = salary * dedRate - cards1 * 0.05 - cards2 * 0.05;
  if (installment <= 0) return { error: "الراتب لا يكفي بعد خصم الالتزامات الحالية." };
  const totalFin = installment * months;
  const approvalAmt = totalFin / (1 + (profitRate * months) / 12);
  const adminFee = Math.min(approvalAmt / 200, 2500);
  const tax = adminFee * 0.15;
  const totalFees = adminFee + tax;
  const bankProfit = (approvalAmt * profitRate * months) / 12;
  const netFinal = approvalAmt - totalFees;
  return {
    max_installment: r(installment), total_financing: r(totalFin), approval_amount: r(approvalAmt),
    admin_fee: r(adminFee), tax_15pct: r(tax), total_fees: r(totalFees), bank_profit: r(bankProfit),
    net_after_fees: r(netFinal), deduction_rate_pct: r(dedRate * 100), months, status: "within_limit",
  };
}

function calcRealEstateStandard(p) {
  const salary = parseFloat(p.salary || 0);
  const mortgageYears = Math.max(1, parseInt(p.mortgage_years || 25));
  const profitRate = parseFloat(p.profit_rate || 4.05) / 100;
  const personalInstall = parseFloat(p.personal_installment || 0);
  const remainingPersonal = parseInt(p.remaining_personal_months || 0);
  const hasHousingSupport = !!p.has_housing_support;
  const hasEtizaz = !!p.has_etizaz;
  if (salary <= 0) return { error: "الراتب يجب أن يكون أكبر من صفر." };
  const totalMonths = mortgageYears * 12;
  const personalPct = salary > 0 ? personalInstall / salary : 0;
  const dedRate = salary >= 15000 ? 0.65 : 0.55;
  const monthlyDed = dedRate * salary;
  const duringInst = salary * (dedRate - personalPct);
  const duringInstCapped = Math.min(duringInst, monthlyDed);
  const afterInst = monthlyDed;
  const remMonths = Math.max(0, totalMonths - remainingPersonal);
  const totalDuring = duringInstCapped * remainingPersonal;
  const totalAfter = afterInst * remMonths;
  const totalWithProfit = totalDuring + totalAfter;
  const maxAmount = totalWithProfit > 0 ? totalWithProfit / (1 + profitRate * mortgageYears) : 0;
  const totalProfit = totalWithProfit - maxAmount;
  let housingVal = 0;
  if (hasHousingSupport) housingVal = salary <= 10000 ? 150000 : 100000;
  const etizazVal = hasEtizaz ? 160000 : 0;
  const grandTotal = maxAmount + housingVal + etizazVal;
  return {
    max_mortgage_amount: r(maxAmount), total_with_profit: r(totalWithProfit), total_profit: r(totalProfit),
    installment_during: r(duringInstCapped), installment_after: r(afterInst),
    remaining_months: remainingPersonal, after_months: remMonths, housing_support: housingVal,
    etizaz_support: etizazVal, grand_total: r(grandTotal), admin_fee: 5750,
    mortgage_years: mortgageYears, deduction_rate_pct: r(dedRate * 100),
  };
}

function calcDeductionRatio(p) {
  const salary = parseFloat(p.salary || 0);
  const jobStatus = (p.job_status || "حكومي").trim();
  const hasRE = !!p.has_real_estate;
  if (salary <= 0) return { error: "الراتب يجب أن يكون أكبر من صفر." };
  const personalRate = jobStatus === "عسكري" ? 0.25 : 0.3333;
  const leasingRate = 0.45;
  const reRate = jobStatus === "عسكري" ? 0.55 : salary < 15000 ? 0.55 : 0.65;
  const effectiveRate = hasRE ? reRate : personalRate;
  return {
    salary, personal_rate_pct: r(personalRate * 100), personal_max_sar: r(salary * personalRate),
    leasing_rate_pct: r(leasingRate * 100), leasing_max_sar: r(salary * leasingRate),
    real_estate_rate_pct: r(reRate * 100), real_estate_max_sar: r(salary * reRate),
    effective_rate_pct: r(effectiveRate * 100), effective_max_sar: r(salary * effectiveRate),
    job_status: jobStatus, note: "نسب ساما المعتمدة 2025",
  };
}

function calcInstallmentDecision(p) {
  const salary = parseFloat(p.salary || 0);
  const jobStatus = (p.job_status || "حكومي").trim();
  const personalDed = parseFloat(p.personal_deduction || 0);
  const leasingDed = parseFloat(p.leasing_deduction || 0);
  const realEstateDed = parseFloat(p.real_estate_deduction || 0);
  const otherDed = parseFloat(p.other_deduction || 0);
  if (salary <= 0) return { error: "الراتب يجب أن يكون أكبر من صفر." };
  const totalDed = personalDed + leasingDed + realEstateDed + otherDed;
  const actualPct = salary > 0 ? totalDed / salary : 0;
  const pct33 = jobStatus === "عسكري" ? 0.25 : 0.3333;
  const pct45 = 0.45;
  const pctRE = salary < 15000 ? 0.55 : 0.65;
  return {
    salary, total_deductions: r(totalDed), actual_deduction_pct: r(actualPct * 100),
    available_for_personal: r(Math.max(0, salary * pct33 - totalDed)),
    available_for_leasing: r(Math.max(0, salary * pct45 - totalDed)),
    available_for_real_estate: r(Math.max(0, salary * pctRE - totalDed)),
    personal_rate_pct: r(pct33 * 100), leasing_rate_pct: r(pct45 * 100),
    real_estate_rate_pct: r(pctRE * 100), status: actualPct > pct33 ? "exceeded" : "within_limit",
  };
}

function calcCommercialAuto(p) {
  const salary = parseFloat(p.salary || 0);
  const carPrice = parseFloat(p.car_price || 0);
  const months = Math.max(12, parseInt(p.months || 60));
  const profitRate = parseFloat(p.profit_rate || 4.7) / 100;
  const downPayPct = parseFloat(p.down_payment_pct || 0) / 100;
  const lastPayPct = parseFloat(p.last_payment_pct || 40) / 100;
  const existingDed = parseFloat(p.existing_deductions || 0);
  const jobStatus = (p.job_status || "حكومي").trim();
  const hasRE = !!p.has_real_estate;
  if (salary <= 0 || carPrice <= 0) return { error: "الراتب وسعر المركبة مطلوبان." };
  const dedRate = hasRE ? (salary < 15000 ? 0.65 : 0.70) : 0.45;
  const available = salary * dedRate - existingDed;
  const downPay = carPrice * downPayPct;
  const lastPay = carPrice * lastPayPct;
  const insurance = 0.0545 * carPrice * (months === 60 ? 3.7087 : (months / 12) * 0.74174);
  const financed = carPrice - downPay;
  const monthly = Math.ceil((financed + financed * profitRate * (months / 12) + insurance - lastPay) / months);
  const total = monthly * months + lastPay + downPay;
  const actualPct = salary > 0 ? (existingDed + monthly) / salary : 0;
  const approved = monthly <= available && salary >= 4000;
  return {
    monthly_installment: monthly, financed_amount: r(financed), down_payment: r(downPay),
    last_payment: r(lastPay), insurance_estimate: r(insurance), total_cost: r(total),
    available_installment: r(Math.max(0, available)), actual_deduction_pct: r(actualPct * 100),
    deduction_rate_pct: r(dedRate * 100), months, approved, status: approved ? "approved" : "not_approved",
  };
}

function calcSalePoints(p) {
  const monthlyPOS = parseFloat(p.monthly_pos || 0);
  const annualSales = parseFloat(p.annual_sales || 0);
  const termMonths = Math.max(12, parseInt(p.term_months || 60));
  const profitRate = parseFloat(p.profit_rate || 8) / 100;
  const entityAge = (p.entity_age || "سنة فأكثر").trim();
  const posAge = (p.pos_age || "سنة فأكثر").trim();
  if (monthlyPOS <= 0) return { error: "متوسط المبيعات الشهرية عبر نقاط البيع مطلوب." };
  const reasons = [];
  if (annualSales > 0 && annualSales < 400000) reasons.push("المبيعات السنوية أقل من 400,000 ريال");
  if (entityAge === "أقل من سنة") reasons.push("عمر المنشأة أقل من سنة");
  if (posAge === "أقل من سنة") reasons.push("عمر نقطة البيع أقل من سنة");
  if (monthlyPOS < 33333.33) reasons.push("متوسط نقاط البيع أقل من 33,333 ريال شهرياً");
  const approved = reasons.length === 0;
  const finAmount = monthlyPOS * 6;
  const termYears = termMonths / 12;
  const totalProfit = finAmount * profitRate * termYears;
  const totalAmount = finAmount + totalProfit;
  const installment = totalAmount / termMonths;
  const adminFee = Math.min(finAmount * 0.05, 2500) * 1.15;
  return {
    approved, rejection_reasons: reasons, financing_amount: r(finAmount),
    monthly_installment: r(installment), total_profit: r(totalProfit), total_amount: r(totalAmount),
    admin_fee: r(adminFee), term_months: termMonths, profit_rate_pct: r(profitRate * 100),
    status: approved ? "approved" : "not_approved",
  };
}

function calcSavings(p) {
  const amount = parseFloat(p.amount || 0);
  const period = (p.period || "شهر").trim();
  if (amount <= 0) return { error: "مبلغ الإيداع مطلوب." };
  if (amount < 100000) return { error: "الحد الأدنى للإيداع 100,000 ريال." };
  const rates = {
    "أسبوعان": { rate: 0.0395, days: 14 }, "ثلاثة أسابيع": { rate: 0.0405, days: 21 },
    "شهر": { rate: 0.0435, days: 30 }, "شهران": { rate: 0.0448, days: 60 },
    "ثلاثة أشهر": { rate: 0.0460, days: 90 }, "ستة أشهر": { rate: 0.0465, days: 180 },
    "تسعة أشهر": { rate: 0.0455, days: 270 }, "سنة": { rate: 0.0445, days: 360 },
  };
  if (!rates[period]) return { error: "الفترة غير صحيحة. الخيارات: " + Object.keys(rates).join(" | ") };
  const rv = rates[period];
  const profit = (amount * rv.rate * rv.days) / 360;
  return { amount, period, days: rv.days, rate_pct: r4(rv.rate * 100), profit: r(profit), total: r(amount + profit), status: "calculated" };
}

function calcSavingsProtection(p) {
  const amount = parseFloat(p.amount || 0);
  const years = Math.max(1, Math.min(30, parseInt(p.years || 3)));
  const investRate = parseFloat(p.invest_rate || 8) / 100;
  if (amount <= 0) return { error: "مبلغ الادخار مطلوب." };
  const coverage = Math.min(Math.max(amount * 0.1, 15000), 250000);
  const partFee = (amount * 55) / 1000;
  const adminFeeY = 420, riskFeeY = 420;
  const rows = [];
  let prevVal = amount;
  for (let y = 1; y <= years; y++) {
    const pf = y === 1 ? partFee : 0;
    const base = prevVal - pf - adminFeeY - riskFeeY;
    const income = base * investRate;
    const invFee = (base + income) * (75 / 10000);
    const cashVal = base + income - invFee;
    rows.push({ year: y, income: r(income), cash_val: r(cashVal), death_val: r(cashVal + coverage), part_fee: r(pf), admin_fee: adminFeeY, risk_fee: riskFeeY, inv_fee: r(invFee) });
    prevVal = cashVal;
  }
  const last = rows[rows.length - 1];
  return {
    initial_amount: amount, years, invest_rate_pct: r(investRate * 100), coverage_amount: coverage,
    final_cash_value: last.cash_val, final_death_value: last.death_val, year_by_year: rows, status: "calculated",
  };
}

// Helpers
function r(n) { return Math.round(n * 100) / 100; }
function r4(n) { return Math.round(n * 10000) / 10000; }

function dispatchTool(name, args) {
  const map = {
    calc_personal_standard: calcPersonalStandard,
    calc_personal_plus: calcPersonalPlus,
    calc_real_estate_standard: calcRealEstateStandard,
    calc_deduction_ratio: calcDeductionRatio,
    calc_installment_decision: calcInstallmentDecision,
    calc_commercial_auto: calcCommercialAuto,
    calc_sale_points: calcSalePoints,
    calc_savings: calcSavings,
    calc_savings_protection: calcSavingsProtection,
  };
  const fn = map[name];
  if (!fn) return { error: "أداة غير معروفة: " + name };
  return fn(args);
}

module.exports = { dispatchTool };
