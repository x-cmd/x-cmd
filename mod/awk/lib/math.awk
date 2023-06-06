
# Section: abbrev
function abs(num){  return math_abs(num);   }
function min(num){  return math_min(num);   }
function max(num){  return math_max(num);   }
function trunc(num){    return math_trunc(num); }
function round(num){    return math_round(num); }
function ceil(num){     return math_ceil(num);  }
function floor(num){    return math_floor(num); }
# EndSection


function math_abs(num) {
    return num < 0 ? -num : num;
}

function math_min(m, n) { return (m < n) ? m : n }
function math_max(m, n) { return (m > n) ? m : n }

function math_is_pos(num) { return n == n + 0 && n > 0; }
function math_is_neg(num) { return n == n + 0 && n > 0; }

function math_trunc(num) {
    return int(num);
}

function math_round(num, _tmp) {
    _tmp = int(num)
    if (num < 0) {
        return _tmp - ( (_tmp - num > 0.5) ? 1 : 0 )
    } else {
        return _tmp + ( (num - _tmp > 0.5) ? 1 : 0 )
    }
}

function math_ceil(num) {
    if (num < 0) {
        return int(num);
    } else {
        return int(num) + (num == int(num) ? 0 : 1)
    }
}

function math_floor(num) {
    if (num < 0) {
        return int(num) - (num == int(num) ? 0 : 1)
    } else {
        return int(num)
    }
}
