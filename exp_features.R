source("init.R")

# Trying to explain first down in target variable and other OHE stuff
tr[, gear_comp_d9 := 1/robot_gear_compression_diff_9]
te[, gear_comp_d9 := 1/robot_gear_compression_diff_9]

tr[, gear_comp_d10 := ifelse(robot_gear_compression_diff_10 < 20 & robot_gear_compression_diff_10 > 0, 1, 0)]
te[, gear_comp_d10 := ifelse(robot_gear_compression_diff_10 < 20 & robot_gear_compression_diff_10 > 0, 1, 0)]

tr[, gear_circ19 := ifelse(robot_gear_circulation_19 > 0, 1, 0)]
te[, gear_circ19 := ifelse(robot_gear_circulation_19 > 0, 1, 0)]

tr[, gear_circ1 := ifelse(robot_gear_circulation_1 < 0, 1, 0)]
te[, gear_circ1 := ifelse(robot_gear_circulation_1 < 0, 1, 0)]

tr[, gear_circ18 := ifelse(robot_gear_circulation_18 < 25 & robot_gear_circulation_18 > -1, 1, 0)]
te[, gear_circ18 := ifelse(robot_gear_circulation_18 < 25 & robot_gear_circulation_18 > -1, 1, 0)]

tr[, prob_circ3 := ifelse(robot_probe_circulation_3 < -100, 1, 0)]
te[, prob_circ3 := ifelse(robot_probe_circulation_3 < -100, 1, 0)]

tr[, prob_temp5 := ifelse(robot_probe_temperature_5 > 10, 1, 0)]
te[, prob_temp5 := ifelse(robot_probe_temperature_5 > 10, 1, 0)]

tr[, eng_temp_26 := ifelse(robot_engine_temperature_26 < -200, 1, 0)]
te[, eng_temp_26 := ifelse(robot_engine_temperature_26 < -200, 1, 0)]

tr[, eng_temp_24 := ifelse(robot_engine_temperature_24 > 100, 1, 0)]
te[, eng_temp_24 := ifelse(robot_engine_temperature_24 > 100, 1, 0)]

tr[, eng_temp_24_less := ifelse(robot_engine_temperature_24 < -50, 1, 0)]
te[, eng_temp_24_less := ifelse(robot_engine_temperature_24 < -50, 1, 0)]

tr[, eng_temp_25 := ifelse(robot_engine_temperature_25 < 0 & robot_engine_temperature_25 > -50, 1, 0)]
te[, eng_temp_25 := ifelse(robot_engine_temperature_25 < 0 & robot_engine_temperature_25 > -50, 1, 0)]
