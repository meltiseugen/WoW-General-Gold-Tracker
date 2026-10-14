local _, NS = ...
local Register = NS.RegisterMaterialFarmingSpot

local function C(x, y, label)
    return { x = x, y = y, label = label }
end

local function RouteCoords(label, packedCoords)
    local coords = {}
    for index, packed in ipairs(packedCoords) do
        local x = math.floor(packed / 10000)
        local y = packed % 10000
        coords[index] = C(x / 10000, y / 10000, string.format("%s pin %d", label, index))
    end
    return coords
end

local RAGVEIL_ZANGARMARSH_MAIN_COORDS = {
    C(0.8646, 0.3365, "Routes Zangarmarsh Ragveil main pin 1"),
    C(0.8374, 0.3628, "Routes Zangarmarsh Ragveil main pin 2"),
    C(0.7950, 0.3677, "Routes Zangarmarsh Ragveil main pin 3"),
    C(0.7859, 0.3988, "Routes Zangarmarsh Ragveil main pin 4"),
    C(0.8045, 0.4182, "Routes Zangarmarsh Ragveil main pin 5"),
    C(0.8266, 0.3922, "Routes Zangarmarsh Ragveil main pin 6"),
    C(0.8514, 0.4170, "Routes Zangarmarsh Ragveil main pin 7"),
    C(0.8286, 0.4241, "Routes Zangarmarsh Ragveil main pin 8"),
    C(0.8231, 0.4860, "Routes Zangarmarsh Ragveil main pin 9"),
    C(0.8168, 0.5011, "Routes Zangarmarsh Ragveil main pin 10"),
    C(0.8184, 0.5711, "Routes Zangarmarsh Ragveil main pin 11"),
    C(0.7941, 0.5756, "Routes Zangarmarsh Ragveil main pin 12"),
    C(0.7715, 0.5613, "Routes Zangarmarsh Ragveil main pin 13"),
    C(0.7611, 0.6244, "Routes Zangarmarsh Ragveil main pin 14"),
    C(0.7882, 0.7316, "Routes Zangarmarsh Ragveil main pin 15"),
    C(0.8125, 0.7145, "Routes Zangarmarsh Ragveil main pin 16"),
    C(0.8269, 0.7533, "Routes Zangarmarsh Ragveil main pin 17"),
    C(0.8578, 0.8028, "Routes Zangarmarsh Ragveil main pin 18"),
    C(0.8211, 0.8096, "Routes Zangarmarsh Ragveil main pin 19"),
    C(0.8277, 0.8451, "Routes Zangarmarsh Ragveil main pin 20"),
    C(0.8601, 0.8631, "Routes Zangarmarsh Ragveil main pin 21"),
    C(0.8384, 0.8821, "Routes Zangarmarsh Ragveil main pin 22"),
    C(0.7968, 0.8448, "Routes Zangarmarsh Ragveil main pin 23"),
    C(0.7657, 0.8235, "Routes Zangarmarsh Ragveil main pin 24"),
    C(0.7341, 0.8316, "Routes Zangarmarsh Ragveil main pin 25"),
    C(0.7032, 0.8123, "Routes Zangarmarsh Ragveil main pin 26"),
    C(0.6767, 0.8129, "Routes Zangarmarsh Ragveil main pin 27"),
    C(0.6965, 0.7868, "Routes Zangarmarsh Ragveil main pin 28"),
    C(0.7024, 0.7563, "Routes Zangarmarsh Ragveil main pin 29"),
    C(0.7163, 0.7606, "Routes Zangarmarsh Ragveil main pin 30"),
    C(0.6902, 0.6690, "Routes Zangarmarsh Ragveil main pin 31"),
    C(0.6901, 0.6493, "Routes Zangarmarsh Ragveil main pin 32"),
    C(0.6879, 0.6293, "Routes Zangarmarsh Ragveil main pin 33"),
    C(0.6722, 0.6079, "Routes Zangarmarsh Ragveil main pin 34"),
    C(0.7104, 0.6060, "Routes Zangarmarsh Ragveil main pin 35"),
    C(0.7113, 0.5087, "Routes Zangarmarsh Ragveil main pin 36"),
    C(0.7113, 0.4628, "Routes Zangarmarsh Ragveil main pin 37"),
    C(0.7091, 0.4077, "Routes Zangarmarsh Ragveil main pin 38"),
    C(0.6874, 0.3956, "Routes Zangarmarsh Ragveil main pin 39"),
    C(0.7209, 0.3715, "Routes Zangarmarsh Ragveil main pin 40"),
    C(0.7327, 0.3352, "Routes Zangarmarsh Ragveil main pin 41"),
    C(0.7550, 0.3378, "Routes Zangarmarsh Ragveil main pin 42"),
    C(0.8125, 0.3191, "Routes Zangarmarsh Ragveil main pin 43"),
}

local RAGVEIL_ZANGARMARSH_ALT_COORDS = {
    C(0.8696, 0.2712, "Routes Zangarmarsh Ragveil alt pin 1"),
    C(0.8700, 0.3090, "Routes Zangarmarsh Ragveil alt pin 2"),
    C(0.8783, 0.3347, "Routes Zangarmarsh Ragveil alt pin 3"),
    C(0.8636, 0.3474, "Routes Zangarmarsh Ragveil alt pin 4"),
    C(0.8371, 0.3674, "Routes Zangarmarsh Ragveil alt pin 5"),
    C(0.8509, 0.4168, "Routes Zangarmarsh Ragveil alt pin 6"),
    C(0.8313, 0.4099, "Routes Zangarmarsh Ragveil alt pin 7"),
    C(0.8313, 0.4401, "Routes Zangarmarsh Ragveil alt pin 8"),
    C(0.8624, 0.4658, "Routes Zangarmarsh Ragveil alt pin 9"),
    C(0.8169, 0.4939, "Routes Zangarmarsh Ragveil alt pin 10"),
    C(0.7912, 0.4802, "Routes Zangarmarsh Ragveil alt pin 11"),
    C(0.7771, 0.4658, "Routes Zangarmarsh Ragveil alt pin 12"),
    C(0.7813, 0.4347, "Routes Zangarmarsh Ragveil alt pin 13"),
    C(0.8032, 0.4170, "Routes Zangarmarsh Ragveil alt pin 14"),
    C(0.7902, 0.3976, "Routes Zangarmarsh Ragveil alt pin 15"),
    C(0.8003, 0.3889, "Routes Zangarmarsh Ragveil alt pin 16"),
    C(0.7952, 0.3648, "Routes Zangarmarsh Ragveil alt pin 17"),
    C(0.7411, 0.4133, "Routes Zangarmarsh Ragveil alt pin 18"),
    C(0.7180, 0.3981, "Routes Zangarmarsh Ragveil alt pin 19"),
    C(0.6993, 0.4350, "Routes Zangarmarsh Ragveil alt pin 20"),
    C(0.6889, 0.3982, "Routes Zangarmarsh Ragveil alt pin 21"),
    C(0.7360, 0.3365, "Routes Zangarmarsh Ragveil alt pin 22"),
    C(0.7611, 0.3060, "Routes Zangarmarsh Ragveil alt pin 23"),
    C(0.7879, 0.2956, "Routes Zangarmarsh Ragveil alt pin 24"),
    C(0.8130, 0.3162, "Routes Zangarmarsh Ragveil alt pin 25"),
    C(0.8420, 0.3319, "Routes Zangarmarsh Ragveil alt pin 26"),
}

local ZANGARMARSH_MIXED_HERB_COORDS = {
    C(0.1843, 0.1767, "Routes Zangarmarsh mixed herb pin 1"),
    C(0.2961, 0.2242, "Routes Zangarmarsh mixed herb pin 2"),
    C(0.3771, 0.2816, "Routes Zangarmarsh mixed herb pin 3"),
    C(0.4665, 0.3311, "Routes Zangarmarsh mixed herb pin 4"),
    C(0.5541, 0.3370, "Routes Zangarmarsh mixed herb pin 5"),
    C(0.6361, 0.3608, "Routes Zangarmarsh mixed herb pin 6"),
    C(0.7458, 0.3647, "Routes Zangarmarsh mixed herb pin 7"),
    C(0.7717, 0.3008, "Routes Zangarmarsh mixed herb pin 8"),
    C(0.8223, 0.2966, "Routes Zangarmarsh mixed herb pin 9"),
    C(0.8714, 0.3470, "Routes Zangarmarsh mixed herb pin 10"),
    C(0.8582, 0.4633, "Routes Zangarmarsh mixed herb pin 11"),
    C(0.8219, 0.5798, "Routes Zangarmarsh mixed herb pin 12"),
    C(0.7517, 0.6113, "Routes Zangarmarsh mixed herb pin 13"),
    C(0.7252, 0.6874, "Routes Zangarmarsh mixed herb pin 14"),
    C(0.8201, 0.7127, "Routes Zangarmarsh mixed herb pin 15"),
    C(0.8485, 0.7936, "Routes Zangarmarsh mixed herb pin 16"),
    C(0.8530, 0.8725, "Routes Zangarmarsh mixed herb pin 17"),
    C(0.7741, 0.8923, "Routes Zangarmarsh mixed herb pin 18"),
    C(0.6890, 0.8477, "Routes Zangarmarsh mixed herb pin 19"),
    C(0.6710, 0.7601, "Routes Zangarmarsh mixed herb pin 20"),
    C(0.6316, 0.6975, "Routes Zangarmarsh mixed herb pin 21"),
    C(0.5466, 0.6889, "Routes Zangarmarsh mixed herb pin 22"),
    C(0.4684, 0.6479, "Routes Zangarmarsh mixed herb pin 23"),
    C(0.3739, 0.6275, "Routes Zangarmarsh mixed herb pin 24"),
    C(0.3186, 0.6520, "Routes Zangarmarsh mixed herb pin 25"),
    C(0.2620, 0.6671, "Routes Zangarmarsh mixed herb pin 26"),
    C(0.1802, 0.6787, "Routes Zangarmarsh mixed herb pin 27"),
    C(0.1327, 0.6288, "Routes Zangarmarsh mixed herb pin 28"),
    C(0.0912, 0.5474, "Routes Zangarmarsh mixed herb pin 29"),
    C(0.1021, 0.4274, "Routes Zangarmarsh mixed herb pin 30"),
    C(0.1505, 0.3467, "Routes Zangarmarsh mixed herb pin 31"),
    C(0.1562, 0.2449, "Routes Zangarmarsh mixed herb pin 32"),
}

local TEROCONE_TEROKKAR_COMPACT_COORDS = {
    C(0.6012, 0.2340, "Routes Terokkar Terocone compact pin 1"),
    C(0.6287, 0.2705, "Routes Terokkar Terocone compact pin 2"),
    C(0.6563, 0.3070, "Routes Terokkar Terocone compact pin 3"),
    C(0.7093, 0.2912, "Routes Terokkar Terocone compact pin 4"),
    C(0.7391, 0.3370, "Routes Terokkar Terocone compact pin 5"),
    C(0.6938, 0.3311, "Routes Terokkar Terocone compact pin 6"),
    C(0.6738, 0.4023, "Routes Terokkar Terocone compact pin 7"),
    C(0.6652, 0.4592, "Routes Terokkar Terocone compact pin 8"),
    C(0.6910, 0.5133, "Routes Terokkar Terocone compact pin 9"),
    C(0.6834, 0.5322, "Routes Terokkar Terocone compact pin 10"),
    C(0.6425, 0.5368, "Routes Terokkar Terocone compact pin 11"),
    C(0.6322, 0.4984, "Routes Terokkar Terocone compact pin 12"),
    C(0.5961, 0.5076, "Routes Terokkar Terocone compact pin 13"),
    C(0.6234, 0.4172, "Routes Terokkar Terocone compact pin 14"),
    C(0.6015, 0.3880, "Routes Terokkar Terocone compact pin 15"),
    C(0.5616, 0.4069, "Routes Terokkar Terocone compact pin 16"),
    C(0.5637, 0.3560, "Routes Terokkar Terocone compact pin 17"),
    C(0.5166, 0.3286, "Routes Terokkar Terocone compact pin 18"),
    C(0.5589, 0.2813, "Routes Terokkar Terocone compact pin 19"),
    C(0.6040, 0.3321, "Routes Terokkar Terocone compact pin 20"),
    C(0.5797, 0.2645, "Routes Terokkar Terocone compact pin 21"),
}

local TEROKKAR_HERBS_MAIN_COORDS = {
    C(0.3208, 0.3763, "Routes Terokkar herbs main pin 1"),
    C(0.2970, 0.3630, "Routes Terokkar herbs main pin 2"),
    C(0.3045, 0.4076, "Routes Terokkar herbs main pin 3"),
    C(0.3207, 0.4465, "Routes Terokkar herbs main pin 4"),
    C(0.3069, 0.4602, "Routes Terokkar herbs main pin 5"),
    C(0.2930, 0.4820, "Routes Terokkar herbs main pin 6"),
    C(0.3244, 0.5128, "Routes Terokkar herbs main pin 7"),
    C(0.2950, 0.5419, "Routes Terokkar herbs main pin 8"),
    C(0.2650, 0.5290, "Routes Terokkar herbs main pin 9"),
    C(0.2426, 0.5548, "Routes Terokkar herbs main pin 10"),
    C(0.2276, 0.5827, "Routes Terokkar herbs main pin 11"),
    C(0.2082, 0.6207, "Routes Terokkar herbs main pin 12"),
    C(0.1737, 0.6555, "Routes Terokkar herbs main pin 13"),
    C(0.1671, 0.7250, "Routes Terokkar herbs main pin 14"),
    C(0.1798, 0.6955, "Routes Terokkar herbs main pin 15"),
    C(0.2139, 0.6886, "Routes Terokkar herbs main pin 16"),
    C(0.2371, 0.6658, "Routes Terokkar herbs main pin 17"),
    C(0.2529, 0.6808, "Routes Terokkar herbs main pin 18"),
    C(0.2633, 0.7156, "Routes Terokkar herbs main pin 19"),
    C(0.2464, 0.7340, "Routes Terokkar herbs main pin 20"),
    C(0.1997, 0.7302, "Routes Terokkar herbs main pin 21"),
    C(0.1875, 0.7380, "Routes Terokkar herbs main pin 22"),
    C(0.1777, 0.7901, "Routes Terokkar herbs main pin 23"),
    C(0.1976, 0.7748, "Routes Terokkar herbs main pin 24"),
    C(0.2260, 0.7816, "Routes Terokkar herbs main pin 25"),
    C(0.2526, 0.7773, "Routes Terokkar herbs main pin 26"),
    C(0.2710, 0.7420, "Routes Terokkar herbs main pin 27"),
    C(0.2920, 0.7809, "Routes Terokkar herbs main pin 28"),
    C(0.2986, 0.7818, "Routes Terokkar herbs main pin 29"),
    C(0.3397, 0.8022, "Routes Terokkar herbs main pin 30"),
    C(0.3332, 0.7518, "Routes Terokkar herbs main pin 31"),
    C(0.3036, 0.7172, "Routes Terokkar herbs main pin 32"),
    C(0.3179, 0.6659, "Routes Terokkar herbs main pin 33"),
    C(0.2926, 0.6651, "Routes Terokkar herbs main pin 34"),
    C(0.2653, 0.6694, "Routes Terokkar herbs main pin 35"),
    C(0.2728, 0.6152, "Routes Terokkar herbs main pin 36"),
    C(0.3085, 0.6336, "Routes Terokkar herbs main pin 37"),
    C(0.3325, 0.6175, "Routes Terokkar herbs main pin 38"),
    C(0.3517, 0.5508, "Routes Terokkar herbs main pin 39"),
    C(0.3777, 0.4945, "Routes Terokkar herbs main pin 40"),
    C(0.3953, 0.5417, "Routes Terokkar herbs main pin 41"),
    C(0.4306, 0.5091, "Routes Terokkar herbs main pin 42"),
    C(0.4380, 0.4750, "Routes Terokkar herbs main pin 43"),
    C(0.4675, 0.4855, "Routes Terokkar herbs main pin 44"),
    C(0.4780, 0.5320, "Routes Terokkar herbs main pin 45"),
    C(0.4438, 0.5440, "Routes Terokkar herbs main pin 46"),
    C(0.4543, 0.6038, "Routes Terokkar herbs main pin 47"),
    C(0.4709, 0.6416, "Routes Terokkar herbs main pin 48"),
    C(0.5059, 0.6344, "Routes Terokkar herbs main pin 49"),
    C(0.4862, 0.5946, "Routes Terokkar herbs main pin 50"),
    C(0.4981, 0.5609, "Routes Terokkar herbs main pin 51"),
    C(0.5168, 0.5422, "Routes Terokkar herbs main pin 52"),
    C(0.5513, 0.5821, "Routes Terokkar herbs main pin 53"),
    C(0.5639, 0.5949, "Routes Terokkar herbs main pin 54"),
    C(0.5665, 0.6145, "Routes Terokkar herbs main pin 55"),
    C(0.5754, 0.6219, "Routes Terokkar herbs main pin 56"),
    C(0.5559, 0.6354, "Routes Terokkar herbs main pin 57"),
    C(0.5687, 0.6492, "Routes Terokkar herbs main pin 58"),
    C(0.5431, 0.6862, "Routes Terokkar herbs main pin 59"),
    C(0.5147, 0.6837, "Routes Terokkar herbs main pin 60"),
    C(0.4850, 0.6682, "Routes Terokkar herbs main pin 61"),
    C(0.4590, 0.6890, "Routes Terokkar herbs main pin 62"),
    C(0.5007, 0.7214, "Routes Terokkar herbs main pin 63"),
    C(0.4858, 0.7642, "Routes Terokkar herbs main pin 64"),
    C(0.4577, 0.7511, "Routes Terokkar herbs main pin 65"),
    C(0.4365, 0.7837, "Routes Terokkar herbs main pin 66"),
    C(0.4271, 0.7492, "Routes Terokkar herbs main pin 67"),
    C(0.4118, 0.7772, "Routes Terokkar herbs main pin 68"),
    C(0.3701, 0.7648, "Routes Terokkar herbs main pin 69"),
    C(0.3843, 0.8131, "Routes Terokkar herbs main pin 70"),
    C(0.4202, 0.8249, "Routes Terokkar herbs main pin 71"),
    C(0.4560, 0.8180, "Routes Terokkar herbs main pin 72"),
    C(0.4905, 0.8257, "Routes Terokkar herbs main pin 73"),
    C(0.5120, 0.8095, "Routes Terokkar herbs main pin 74"),
    C(0.5336, 0.7909, "Routes Terokkar herbs main pin 75"),
    C(0.5360, 0.7560, "Routes Terokkar herbs main pin 76"),
    C(0.5676, 0.7143, "Routes Terokkar herbs main pin 77"),
    C(0.5734, 0.6684, "Routes Terokkar herbs main pin 78"),
    C(0.6160, 0.7324, "Routes Terokkar herbs main pin 79"),
    C(0.6160, 0.7710, "Routes Terokkar herbs main pin 80"),
    C(0.6180, 0.8210, "Routes Terokkar herbs main pin 81"),
    C(0.6569, 0.7921, "Routes Terokkar herbs main pin 82"),
    C(0.6564, 0.8641, "Routes Terokkar herbs main pin 83"),
    C(0.6923, 0.8650, "Routes Terokkar herbs main pin 84"),
    C(0.7215, 0.8849, "Routes Terokkar herbs main pin 85"),
    C(0.7494, 0.8746, "Routes Terokkar herbs main pin 86"),
    C(0.7424, 0.8448, "Routes Terokkar herbs main pin 87"),
    C(0.7639, 0.8034, "Routes Terokkar herbs main pin 88"),
    C(0.7203, 0.8072, "Routes Terokkar herbs main pin 89"),
    C(0.7275, 0.7302, "Routes Terokkar herbs main pin 90"),
    C(0.6921, 0.7463, "Routes Terokkar herbs main pin 91"),
    C(0.6588, 0.6922, "Routes Terokkar herbs main pin 92"),
    C(0.6373, 0.6597, "Routes Terokkar herbs main pin 93"),
    C(0.6367, 0.5769, "Routes Terokkar herbs main pin 94"),
    C(0.6597, 0.5606, "Routes Terokkar herbs main pin 95"),
    C(0.6872, 0.5348, "Routes Terokkar herbs main pin 96"),
    C(0.6921, 0.5099, "Routes Terokkar herbs main pin 97"),
    C(0.7005, 0.4351, "Routes Terokkar herbs main pin 98"),
    C(0.7241, 0.4503, "Routes Terokkar herbs main pin 99"),
    C(0.7430, 0.3741, "Routes Terokkar herbs main pin 100"),
    C(0.7277, 0.3330, "Routes Terokkar herbs main pin 101"),
    C(0.7143, 0.2910, "Routes Terokkar herbs main pin 102"),
    C(0.6965, 0.3206, "Routes Terokkar herbs main pin 103"),
    C(0.6884, 0.3540, "Routes Terokkar herbs main pin 104"),
    C(0.6722, 0.3967, "Routes Terokkar herbs main pin 105"),
    C(0.6541, 0.3723, "Routes Terokkar herbs main pin 106"),
    C(0.6600, 0.3300, "Routes Terokkar herbs main pin 107"),
    C(0.6624, 0.3027, "Routes Terokkar herbs main pin 108"),
    C(0.6336, 0.2990, "Routes Terokkar herbs main pin 109"),
    C(0.6311, 0.3488, "Routes Terokkar herbs main pin 110"),
    C(0.6412, 0.4220, "Routes Terokkar herbs main pin 111"),
    C(0.6740, 0.4301, "Routes Terokkar herbs main pin 112"),
    C(0.6688, 0.4840, "Routes Terokkar herbs main pin 113"),
    C(0.6413, 0.5361, "Routes Terokkar herbs main pin 114"),
    C(0.6113, 0.5567, "Routes Terokkar herbs main pin 115"),
    C(0.6051, 0.5186, "Routes Terokkar herbs main pin 116"),
    C(0.6028, 0.4869, "Routes Terokkar herbs main pin 117"),
    C(0.6239, 0.4970, "Routes Terokkar herbs main pin 118"),
    C(0.6399, 0.5002, "Routes Terokkar herbs main pin 119"),
    C(0.6085, 0.4496, "Routes Terokkar herbs main pin 120"),
    C(0.6195, 0.4364, "Routes Terokkar herbs main pin 121"),
    C(0.6171, 0.3945, "Routes Terokkar herbs main pin 122"),
    C(0.5885, 0.4133, "Routes Terokkar herbs main pin 123"),
    C(0.5604, 0.4081, "Routes Terokkar herbs main pin 124"),
    C(0.5374, 0.4277, "Routes Terokkar herbs main pin 125"),
    C(0.5599, 0.3772, "Routes Terokkar herbs main pin 126"),
    C(0.5484, 0.3489, "Routes Terokkar herbs main pin 127"),
    C(0.5705, 0.3450, "Routes Terokkar herbs main pin 128"),
    C(0.5891, 0.3683, "Routes Terokkar herbs main pin 129"),
    C(0.6015, 0.3174, "Routes Terokkar herbs main pin 130"),
    C(0.6142, 0.2663, "Routes Terokkar herbs main pin 131"),
    C(0.6097, 0.2260, "Routes Terokkar herbs main pin 132"),
    C(0.5778, 0.2550, "Routes Terokkar herbs main pin 133"),
    C(0.5862, 0.2836, "Routes Terokkar herbs main pin 134"),
    C(0.5544, 0.2884, "Routes Terokkar herbs main pin 135"),
    C(0.5381, 0.2865, "Routes Terokkar herbs main pin 136"),
    C(0.5465, 0.2512, "Routes Terokkar herbs main pin 137"),
    C(0.5140, 0.2253, "Routes Terokkar herbs main pin 138"),
    C(0.4881, 0.2187, "Routes Terokkar herbs main pin 139"),
    C(0.5115, 0.1790, "Routes Terokkar herbs main pin 140"),
    C(0.5065, 0.1541, "Routes Terokkar herbs main pin 141"),
    C(0.4859, 0.1797, "Routes Terokkar herbs main pin 142"),
    C(0.4735, 0.1424, "Routes Terokkar herbs main pin 143"),
    C(0.4504, 0.1622, "Routes Terokkar herbs main pin 144"),
    C(0.4438, 0.1914, "Routes Terokkar herbs main pin 145"),
    C(0.4312, 0.1681, "Routes Terokkar herbs main pin 146"),
    C(0.4419, 0.1311, "Routes Terokkar herbs main pin 147"),
    C(0.4300, 0.0830, "Routes Terokkar herbs main pin 148"),
    C(0.3626, 0.0862, "Routes Terokkar herbs main pin 149"),
    C(0.3127, 0.0775, "Routes Terokkar herbs main pin 150"),
    C(0.3902, 0.1461, "Routes Terokkar herbs main pin 151"),
    C(0.3730, 0.2884, "Routes Terokkar herbs main pin 152"),
    C(0.3866, 0.3109, "Routes Terokkar herbs main pin 153"),
    C(0.4140, 0.2928, "Routes Terokkar herbs main pin 154"),
    C(0.4076, 0.2335, "Routes Terokkar herbs main pin 155"),
    C(0.4325, 0.2421, "Routes Terokkar herbs main pin 156"),
    C(0.4631, 0.2456, "Routes Terokkar herbs main pin 157"),
    C(0.4839, 0.2545, "Routes Terokkar herbs main pin 158"),
    C(0.5078, 0.2681, "Routes Terokkar herbs main pin 159"),
    C(0.5007, 0.3249, "Routes Terokkar herbs main pin 160"),
    C(0.5034, 0.3647, "Routes Terokkar herbs main pin 161"),
    C(0.4815, 0.3446, "Routes Terokkar herbs main pin 162"),
    C(0.4674, 0.3509, "Routes Terokkar herbs main pin 163"),
    C(0.4776, 0.2973, "Routes Terokkar herbs main pin 164"),
    C(0.4435, 0.2878, "Routes Terokkar herbs main pin 165"),
    C(0.4498, 0.3180, "Routes Terokkar herbs main pin 166"),
    C(0.4313, 0.3377, "Routes Terokkar herbs main pin 167"),
    C(0.4258, 0.3635, "Routes Terokkar herbs main pin 168"),
    C(0.3944, 0.3697, "Routes Terokkar herbs main pin 169"),
    C(0.3885, 0.3468, "Routes Terokkar herbs main pin 170"),
    C(0.3691, 0.3721, "Routes Terokkar herbs main pin 171"),
    C(0.3861, 0.3898, "Routes Terokkar herbs main pin 172"),
    C(0.4098, 0.4183, "Routes Terokkar herbs main pin 173"),
    C(0.3798, 0.4318, "Routes Terokkar herbs main pin 174"),
    C(0.3411, 0.4245, "Routes Terokkar herbs main pin 175"),
    C(0.3300, 0.3997, "Routes Terokkar herbs main pin 176"),
}

local NETHERBLOOM_NETHERSTORM_MAIN_COORDS = {
    C(0.3628, 0.1901, "Routes Netherstorm Netherbloom main pin 1"),
    C(0.4578, 0.1253, "Routes Netherstorm Netherbloom main pin 2"),
    C(0.5440, 0.1960, "Routes Netherstorm Netherbloom main pin 3"),
    C(0.5730, 0.2455, "Routes Netherstorm Netherbloom main pin 4"),
    C(0.5754, 0.3772, "Routes Netherstorm Netherbloom main pin 5"),
    C(0.6495, 0.3177, "Routes Netherstorm Netherbloom main pin 6"),
    C(0.7059, 0.3895, "Routes Netherstorm Netherbloom main pin 7"),
    C(0.6287, 0.4606, "Routes Netherstorm Netherbloom main pin 8"),
    C(0.5544, 0.4560, "Routes Netherstorm Netherbloom main pin 9"),
    C(0.4933, 0.5558, "Routes Netherstorm Netherbloom main pin 10"),
    C(0.5574, 0.5996, "Routes Netherstorm Netherbloom main pin 11"),
    C(0.6674, 0.6122, "Routes Netherstorm Netherbloom main pin 12"),
    C(0.6041, 0.6830, "Routes Netherstorm Netherbloom main pin 13"),
    C(0.5245, 0.6850, "Routes Netherstorm Netherbloom main pin 14"),
    C(0.5201, 0.7579, "Routes Netherstorm Netherbloom main pin 15"),
    C(0.6001, 0.8064, "Routes Netherstorm Netherbloom main pin 16"),
    C(0.5526, 0.8789, "Routes Netherstorm Netherbloom main pin 17"),
    C(0.4706, 0.8113, "Routes Netherstorm Netherbloom main pin 18"),
    C(0.3996, 0.6461, "Routes Netherstorm Netherbloom main pin 19"),
    C(0.3303, 0.7933, "Routes Netherstorm Netherbloom main pin 20"),
    C(0.2606, 0.7834, "Routes Netherstorm Netherbloom main pin 21"),
    C(0.1968, 0.7156, "Routes Netherstorm Netherbloom main pin 22"),
    C(0.2464, 0.6671, "Routes Netherstorm Netherbloom main pin 23"),
    C(0.2546, 0.5719, "Routes Netherstorm Netherbloom main pin 24"),
    C(0.2375, 0.3792, "Routes Netherstorm Netherbloom main pin 25"),
    C(0.2716, 0.3601, "Routes Netherstorm Netherbloom main pin 26"),
    C(0.3086, 0.4032, "Routes Netherstorm Netherbloom main pin 27"),
    C(0.3484, 0.3695, "Routes Netherstorm Netherbloom main pin 28"),
    C(0.3326, 0.2876, "Routes Netherstorm Netherbloom main pin 29"),
}

local NETHERSTORM_MIXED_HERB_COORDS = {
    C(0.4609, 0.1430, "Routes Netherstorm mixed herb pin 1"),
    C(0.5106, 0.1953, "Routes Netherstorm mixed herb pin 2"),
    C(0.5629, 0.2161, "Routes Netherstorm mixed herb pin 3"),
    C(0.5989, 0.3071, "Routes Netherstorm mixed herb pin 4"),
    C(0.6616, 0.3266, "Routes Netherstorm mixed herb pin 5"),
    C(0.7131, 0.3953, "Routes Netherstorm mixed herb pin 6"),
    C(0.6876, 0.4707, "Routes Netherstorm mixed herb pin 7"),
    C(0.6292, 0.5045, "Routes Netherstorm mixed herb pin 8"),
    C(0.6561, 0.5978, "Routes Netherstorm mixed herb pin 9"),
    C(0.6373, 0.6517, "Routes Netherstorm mixed herb pin 10"),
    C(0.5722, 0.6704, "Routes Netherstorm mixed herb pin 11"),
    C(0.5090, 0.6761, "Routes Netherstorm mixed herb pin 12"),
    C(0.4356, 0.7153, "Routes Netherstorm mixed herb pin 13"),
    C(0.3772, 0.7699, "Routes Netherstorm mixed herb pin 14"),
    C(0.3173, 0.7562, "Routes Netherstorm mixed herb pin 15"),
    C(0.2239, 0.7606, "Routes Netherstorm mixed herb pin 16"),
    C(0.1954, 0.7080, "Routes Netherstorm mixed herb pin 17"),
    C(0.2369, 0.6455, "Routes Netherstorm mixed herb pin 18"),
    C(0.2619, 0.5740, "Routes Netherstorm mixed herb pin 19"),
    C(0.3225, 0.5220, "Routes Netherstorm mixed herb pin 20"),
    C(0.3814, 0.4140, "Routes Netherstorm mixed herb pin 21"),
    C(0.3897, 0.3604, "Routes Netherstorm mixed herb pin 22"),
    C(0.3402, 0.2928, "Routes Netherstorm mixed herb pin 23"),
    C(0.3707, 0.2013, "Routes Netherstorm mixed herb pin 24"),
}

local NIGHTMARE_VINE_SHADOWMOON_COORDS = {
    C(0.2491, 0.2984, "Routes Shadowmoon Nightmare Vine pin 1"),
    C(0.3171, 0.3507, "Routes Shadowmoon Nightmare Vine pin 2"),
    C(0.3851, 0.3015, "Routes Shadowmoon Nightmare Vine pin 3"),
    C(0.3736, 0.3656, "Routes Shadowmoon Nightmare Vine pin 4"),
    C(0.4347, 0.3295, "Routes Shadowmoon Nightmare Vine pin 5"),
    C(0.4251, 0.3919, "Routes Shadowmoon Nightmare Vine pin 6"),
    C(0.4364, 0.4193, "Routes Shadowmoon Nightmare Vine pin 7"),
    C(0.4666, 0.4026, "Routes Shadowmoon Nightmare Vine pin 8"),
    C(0.4739, 0.3244, "Routes Shadowmoon Nightmare Vine pin 9"),
    C(0.5022, 0.3320, "Routes Shadowmoon Nightmare Vine pin 10"),
    C(0.5696, 0.2966, "Routes Shadowmoon Nightmare Vine pin 11"),
    C(0.5352, 0.3506, "Routes Shadowmoon Nightmare Vine pin 12"),
    C(0.5818, 0.3517, "Routes Shadowmoon Nightmare Vine pin 13"),
    C(0.5970, 0.3680, "Routes Shadowmoon Nightmare Vine pin 14"),
    C(0.5623, 0.4007, "Routes Shadowmoon Nightmare Vine pin 15"),
    C(0.5692, 0.4403, "Routes Shadowmoon Nightmare Vine pin 16"),
    C(0.6137, 0.4423, "Routes Shadowmoon Nightmare Vine pin 17"),
    C(0.6512, 0.3944, "Routes Shadowmoon Nightmare Vine pin 18"),
    C(0.6773, 0.4152, "Routes Shadowmoon Nightmare Vine pin 19"),
    C(0.7162, 0.4167, "Routes Shadowmoon Nightmare Vine pin 20"),
    C(0.7250, 0.4654, "Routes Shadowmoon Nightmare Vine pin 21"),
    C(0.6741, 0.4655, "Routes Shadowmoon Nightmare Vine pin 22"),
    C(0.6735, 0.5287, "Routes Shadowmoon Nightmare Vine pin 23"),
    C(0.6206, 0.5720, "Routes Shadowmoon Nightmare Vine pin 24"),
    C(0.6504, 0.6100, "Routes Shadowmoon Nightmare Vine pin 25"),
    C(0.6032, 0.6747, "Routes Shadowmoon Nightmare Vine pin 26"),
    C(0.5658, 0.7296, "Routes Shadowmoon Nightmare Vine pin 27"),
    C(0.5236, 0.6905, "Routes Shadowmoon Nightmare Vine pin 28"),
    C(0.5174, 0.5980, "Routes Shadowmoon Nightmare Vine pin 29"),
    C(0.4775, 0.6423, "Routes Shadowmoon Nightmare Vine pin 30"),
    C(0.4681, 0.7151, "Routes Shadowmoon Nightmare Vine pin 31"),
    C(0.4339, 0.7321, "Routes Shadowmoon Nightmare Vine pin 32"),
    C(0.4382, 0.6715, "Routes Shadowmoon Nightmare Vine pin 33"),
    C(0.4316, 0.6219, "Routes Shadowmoon Nightmare Vine pin 34"),
    C(0.4432, 0.5799, "Routes Shadowmoon Nightmare Vine pin 35"),
    C(0.4149, 0.5732, "Routes Shadowmoon Nightmare Vine pin 36"),
    C(0.4727, 0.5226, "Routes Shadowmoon Nightmare Vine pin 37"),
    C(0.4453, 0.4871, "Routes Shadowmoon Nightmare Vine pin 38"),
    C(0.4189, 0.4849, "Routes Shadowmoon Nightmare Vine pin 39"),
    C(0.3758, 0.4577, "Routes Shadowmoon Nightmare Vine pin 40"),
    C(0.3543, 0.5091, "Routes Shadowmoon Nightmare Vine pin 41"),
    C(0.2981, 0.5375, "Routes Shadowmoon Nightmare Vine pin 42"),
    C(0.2765, 0.5302, "Routes Shadowmoon Nightmare Vine pin 43"),
    C(0.2949, 0.4626, "Routes Shadowmoon Nightmare Vine pin 44"),
    C(0.3355, 0.4134, "Routes Shadowmoon Nightmare Vine pin 45"),
    C(0.2927, 0.3836, "Routes Shadowmoon Nightmare Vine pin 46"),
    C(0.2614, 0.3610, "Routes Shadowmoon Nightmare Vine pin 47"),
}

local NIGHTMARE_VINE_BLADES_EDGE_COORDS = {
    C(0.6510, 0.2064, "Routes Blades Edge Nightmare Vine alt pin 1"),
    C(0.7096, 0.2334, "Routes Blades Edge Nightmare Vine alt pin 2"),
    C(0.7128, 0.2842, "Routes Blades Edge Nightmare Vine alt pin 3"),
    C(0.7072, 0.3520, "Routes Blades Edge Nightmare Vine alt pin 4"),
    C(0.6908, 0.4204, "Routes Blades Edge Nightmare Vine alt pin 5"),
    C(0.6685, 0.4820, "Routes Blades Edge Nightmare Vine alt pin 6"),
    C(0.6661, 0.5535, "Routes Blades Edge Nightmare Vine alt pin 7"),
    C(0.6797, 0.6311, "Routes Blades Edge Nightmare Vine alt pin 8"),
    C(0.6860, 0.7071, "Routes Blades Edge Nightmare Vine alt pin 9"),
    C(0.6669, 0.7650, "Routes Blades Edge Nightmare Vine alt pin 10"),
    C(0.6120, 0.7752, "Routes Blades Edge Nightmare Vine alt pin 11"),
    C(0.5935, 0.7046, "Routes Blades Edge Nightmare Vine alt pin 12"),
    C(0.5485, 0.7041, "Routes Blades Edge Nightmare Vine alt pin 13"),
    C(0.5204, 0.7228, "Routes Blades Edge Nightmare Vine alt pin 14"),
    C(0.4856, 0.7067, "Routes Blades Edge Nightmare Vine alt pin 15"),
    C(0.4500, 0.7616, "Routes Blades Edge Nightmare Vine alt pin 16"),
    C(0.4477, 0.6913, "Routes Blades Edge Nightmare Vine alt pin 17"),
    C(0.4021, 0.5804, "Routes Blades Edge Nightmare Vine alt pin 18"),
    C(0.4152, 0.4932, "Routes Blades Edge Nightmare Vine alt pin 19"),
    C(0.4864, 0.4099, "Routes Blades Edge Nightmare Vine alt pin 20"),
    C(0.5458, 0.3601, "Routes Blades Edge Nightmare Vine alt pin 21"),
    C(0.5866, 0.2369, "Routes Blades Edge Nightmare Vine alt pin 22"),
}

local function RegisterHerb(itemID, itemName, sourceUrls, summary, spot)
    if type(spot) == "table" and type(spot.coords) == "table" and #spot.coords > 1 then
        spot.isRoute = true
    end
    Register({
        itemID = itemID,
        itemName = itemName,
        expansion = "burningCrusade",
        professions = { "herbalism", "alchemy", "inscription" },
        category = "Herb",
        researchStatus = "researched",
        sourceUrls = sourceUrls,
        summary = summary,
        spots = { spot },
    })
end

local function CatalogHerbSpot(id, sourceUrls, mapName, location, density, difficulty, tips, coords, routeType, confidence)
    return {
        id = id,
        source = "Routes import string, farming route notes, and retail-safe herb source cross-checks",
        sourceUrls = sourceUrls,
        mapName = mapName,
        location = location,
        routeType = routeType or "herbalism-loop",
        isRoute = true,
        density = density,
        dropDifficulty = difficulty,
        tips = tips,
        coords = coords,
        confidence = confidence or "high",
    }
end

local function AppendCatalogHerbSpot(itemID, spot)
    local item = NS.MaterialFarmingSpots.items[itemID]
    if item then
        item.spots[#item.spots + 1] = spot
    end
end

local XSCARLIFE_ROUTES = "https://xscarlife-gaming.com/farming-retail/"
local FELWEED_GUIDE = "https://www.wow-professions.com/farming/felweed-farming"

-- Routes stores each point as xxxxYYYY: four digits of normalized X followed
-- by four digits of normalized Y. Keep the source order because it defines
-- the connected path.
local SUPPLIED_BLOODTHISTLE_MAIN = RouteCoords("Bloodthistle main", {
    36004800, 38005500, 48006100, 60005900, 69005200, 70004300, 61003500, 48003100, 39003800,
})
local SUPPLIED_BLOODTHISTLE_ALT = RouteCoords("Bloodthistle alternative", {
    53004400, 49004900, 50005600, 57006100, 64005600, 63004800, 59004100,
})
local SUPPLIED_BLADES_EDGE_COMMON = RouteCoords("Blade's Edge common-herb", {
    39172290, 47532134, 60181112, 69511051, 73951856, 60312556, 54814312,
    62935423, 70446333, 76597552, 68807605, 62057786, 56996817, 56867302,
    52887509, 50996939, 46716856, 39187445, 29768045, 30815240, 35994137,
    29402636, 33852185,
})
local SUPPLIED_FELWEED_NAGRAND_ALT = RouteCoords("Felweed Nagrand alternative", {
    30282090, 42122174, 47672516, 53962257, 50363556, 54604567, 67773828,
    71694454, 59815085, 56025301, 56536028, 63246101, 69945685, 75786054,
    71117111, 71957817, 69988345, 65577918, 59827957, 47937869, 51686515,
    51425361, 40475633, 42957230, 39347928, 29837889, 28646207, 24075322,
    19805324, 22334202, 37753291, 27252946, 23102890, 26022290,
})
local SUPPLIED_DREAMING_GLORY_NAGRAND_ALT = SUPPLIED_FELWEED_NAGRAND_ALT
local SUPPLIED_RAGVEIL_MAIN = RouteCoords("Ragveil main", {
    19021912, 36862678, 40373718, 46213225, 54703445, 60383342, 65184306,
    66203337, 70623167, 71914483, 75353984, 77443042, 86542889, 87694232,
    83795686, 81046783, 86078400, 82079122, 73328800, 65027444, 56577000,
    46336592, 40006450, 28333522, 25104728, 20995467, 19616312, 9726107,
    8485193, 10214457, 15813696, 16232615,
})
local SUPPLIED_TEROKKAR_FOREST = RouteCoords("Terokkar northern forest", {
    46211767, 53592289, 61672906, 65453104, 71743079, 68463760, 71564707,
    65895447, 61604482, 55314495, 57116367, 53497548, 49438017, 39607922,
    31327738, 31516460, 24936414, 24577547, 19317545, 21206056, 28875095,
    33713912,
})
local SUPPLIED_FLAME_CAP_MAIN = SUPPLIED_RAGVEIL_MAIN
local SUPPLIED_FLAME_CAP_ALT = RAGVEIL_ZANGARMARSH_ALT_COORDS
local SUPPLIED_SHADOWMOON = RouteCoords("Shadowmoon mixed-herb", {
    29322879, 38752843, 47442250, 49842083, 52541494, 57311760, 53423669,
    58493124, 68433000, 56264131, 63784374, 64275117, 69355703, 60045751,
    61856333, 60466783, 54026922, 52146417, 49076311, 47606800, 45997111,
    42546783, 41306233, 47365972, 46095267, 31095645, 28144999, 27404240,
    20433871, 22883231,
})
local SUPPLIED_SLAVE_PENS = RouteCoords("Slave Pens Ancient Lichen", {
    55001800, 55002800, 48003800, 43004800, 48005800, 55006800,
    48007600, 38006800, 34005600, 38004400, 34003200,
})
local SUPPLIED_UNDERBOG = RouteCoords("Underbog Ancient Lichen", {
    62001600, 58002700, 48003600, 42004600, 48005700, 39006700,
    48007600, 61006900, 67005600, 61004300, 70003000,
})
local SUPPLIED_NETHERSTORM_MAIN = RouteCoords("Netherstorm full", {
    36281901, 45781253, 54401960, 57302455, 57543772, 64953177, 70593895,
    62874606, 55444560, 49335558, 55745996, 66746122, 60416830, 52456850,
    52017579, 60018064, 55268789, 47068113, 39966461, 33037933, 26067834,
    19687156, 24646671, 25465719, 23753792, 27163601, 30864032, 34843695,
    33262876,
})
local SUPPLIED_NETHERSTORM_ALT = NETHERSTORM_MIXED_HERB_COORDS
local SUPPLIED_NIGHTMARE_VINE_ALT = SUPPLIED_BLADES_EDGE_COMMON
local SUPPLIED_MANA_THISTLE_MAIN = RouteCoords("Mana Thistle main", {
    27006800, 31007600, 29008700, 35009200, 40008200, 37006800, 48007500,
    55008700, 64007900, 71006500, 68005500, 60006200, 52006600, 44006000,
})
local SUPPLIED_MANA_THISTLE_ALT = RouteCoords("Mana Thistle Skettis alternative", {
    61006500, 67007000, 72007700, 68008400, 61008200, 56007500, 57006800,
})

local function SuppliedHerbRoute(id, mapID, mapName, location, coords, sourceUrls, tips, density, difficulty, routeType)
    return {
        id = id,
        source = "Supplied validated Retail Routes import with public-route source cross-checks",
        sourceUrls = sourceUrls,
        mapID = mapID,
        mapName = mapName,
        location = location,
        routeType = routeType or "herbalism-loop",
        isRoute = true,
        density = density,
        dropDifficulty = difficulty,
        tips = tips,
        coords = coords,
        confidence = "high",
    }
end

Register({
    itemID = 22710,
    itemName = "Bloodthistle",
    expansion = "burningCrusade",
    professions = { "herbalism" },
    category = "Herb",
    researchStatus = "researched",
    sourceUrls = { XSCARLIFE_ROUTES, "https://www.wowhead.com/item=22710/bloodthistle" },
    summary = "Bloodthistle grows around blood-elf settlements and structures in Eversong Woods; both supplied circuits are compact ground routes.",
    spots = {
        SuppliedHerbRoute(
            "bloodthistle-eversong-outer-settlements-main",
            94,
            "Eversong Woods",
            "Main - outer settlements circuit",
            SUPPLIED_BLOODTHISTLE_MAIN,
            { XSCARLIFE_ROUTES, "https://www.wowhead.com/item=22710/bloodthistle" },
            {
                "Search around blood-elf buildings, walls, roads, ruins, and mana-powered structures.",
                "Do not treat it like a normal wilderness herb; isolated forest sections are less productive.",
                "Pick every Bloodthistle along the circuit so nodes can recycle.",
                "This is a compact ground-mount route because flying is normally unavailable in Eversong Woods.",
            },
            "Localized around blood-elf structures",
            "Easy compact ground route"
        ),
        SuppliedHerbRoute(
            "bloodthistle-eversong-central-settlements-alternative",
            94,
            "Eversong Woods",
            "Alternative - central settlement circuit",
            SUPPLIED_BLOODTHISTLE_ALT,
            { XSCARLIFE_ROUTES, "https://www.wowhead.com/item=22710/bloodthistle" },
            {
                "Use this shorter route when the outer circuit is producing empty stretches.",
                "Search both sides of paths and immediately behind buildings.",
                "Bloodthistle can be easy to miss among Eversong's red vegetation; node-tracking icons help considerably.",
            },
            "Localized and compact",
            "Easy short ground route"
        ),
    },
})

RegisterHerb(22785, "Felweed", {
    "https://www.wowhead.com/object=181270/felweed",
    "https://www.wow-professions.com/farming/felweed-farming",
    "https://warcraft.wiki.gg/wiki/Felweed",
    "https://artisansofazeroth.com/felweed-farming/",
}, "Common Outland herb. Hellfire Peninsula and Nagrand have dense node maps; gather every nearby herb to keep replacements moving.", {
    id = "felweed-hellfire-peninsula-loop",
    source = "Wowhead object map pins and Outland herb farming guides",
    sourceUrls = {
        "https://www.wowhead.com/object=181270/felweed",
        "https://www.wow-professions.com/farming/felweed-farming",
    },
    mapName = "Hellfire Peninsula",
    location = "Outer Hellfire herb loop through cliffs, ruins, and Hellfire Citadel approaches",
    routeType = "herbalism-loop",
    density = "High",
    dropDifficulty = "Easy. The zone is broad, so shorten the loop if respawns keep up.",
    tips = {
        "Gather every herb on the path, not just Felweed.",
        "The western and southern cliff lines are easy to combine with Fel Iron mining.",
    },
    coords = {
        C(0.109, 0.544, "Western Hellfire Felweed"),
        C(0.158, 0.608, "Southwest ridge Felweed"),
        C(0.202, 0.467, "Hellfire Citadel approach herb"),
        C(0.307, 0.485, "Central Hellfire herb"),
        C(0.398, 0.519, "Path of Glory herb"),
        C(0.488, 0.591, "Southern Hellfire herb"),
        C(0.584, 0.513, "Eastern Path of Glory Felweed"),
        C(0.667, 0.771, "Southeast Hellfire herb"),
        C(0.724, 0.636, "Zeth'gor side herb"),
    },
    confidence = "high",
})

local felweed = NS.MaterialFarmingSpots.items[22785]
if felweed then
    felweed.spots[#felweed.spots + 1] = {
        id = "felweed-nagrand-aoa-dreaming-glory-loop",
        source = "Artisans of Azeroth Routes import string, wow-professions Felweed guide, and Wowhead Felweed object page",
        sourceUrls = {
            "https://artisansofazeroth.com/felweed-farming/",
            "https://www.wow-professions.com/farming/felweed-farming",
            "https://www.wowhead.com/object=181270/felweed",
        },
        mapName = "Nagrand",
        location = "Nagrand Felweed and Dreaming Glory mixed herb loop",
        routeType = "herbalism-loop",
        density = "High for common Outland herbs",
        dropDifficulty = "Easy. Use this when Felweed value is good and you want a smoother common-herb route than Hellfire.",
        tips = {
            "The Artisans route string provides a compact Nagrand loop; wow-professions cross-checks Nagrand as a strong Felweed zone.",
            "Gather Dreaming Glory and Mana Thistle side checks while keeping Felweed as the baseline target.",
        },
        coords = {
            C(0.2768, 0.6189, "AoA Nagrand Felweed route start"),
            C(0.2861, 0.5936, "AoA west Nagrand Felweed pin"),
            C(0.3470, 0.6371, "AoA central-west Nagrand Felweed pin"),
            C(0.3745, 0.6491, "AoA south-central Nagrand Felweed pin"),
            C(0.4165, 0.6051, "AoA central Nagrand Felweed pin"),
            C(0.4885, 0.5521, "AoA east-central Nagrand Felweed pin"),
            C(0.5320, 0.6005, "AoA eastern Nagrand Felweed pin"),
            C(0.5568, 0.5902, "AoA far-east Nagrand Felweed pin"),
        },
        confidence = "medium",
    }
end

RegisterHerb(22786, "Dreaming Glory", {
    "https://www.wowhead.com/object=181271/dreaming-glory",
    "https://warcraft.wiki.gg/wiki/Dreaming_Glory",
    "https://www.wow-professions.com/farming/felweed-farming",
    "https://artisansofazeroth.com/felweed-farming/",
}, "Common Outland herb that favors cliffsides and raised terrain. Nagrand and Blade's Edge routes pair it with Felweed, Mana Thistle, and Nightmare Vine.", {
    id = "dreaming-glory-nagrand-cliff-loop",
    source = "Wowhead object map pins and Outland herb farming guides",
    sourceUrls = {
        "https://www.wowhead.com/object=181271/dreaming-glory",
        "https://warcraft.wiki.gg/wiki/Dreaming_Glory",
        "https://artisansofazeroth.com/felweed-farming/",
    },
    mapName = "Nagrand",
    location = "Nagrand cliffs, raised ground, Twilight Ridge, and western ridgelines",
    routeType = "herbalism-loop",
    density = "High",
    dropDifficulty = "Easy. Best treated as side value while sweeping high terrain.",
    tips = {
        "Follow cliffs and raised ground rather than flat-only loops.",
        "Add Twilight Ridge checks for Mana Thistle and Cobra Scales side routes.",
    },
    coords = {
        C(0.071, 0.436, "Northwest cliff Dreaming Glory"),
        C(0.147, 0.355, "Twilight Ridge Dreaming Glory"),
        C(0.242, 0.557, "Western ridge Dreaming Glory"),
        C(0.2768, 0.6189, "AoA Nagrand Felweed/Dreaming Glory route pin"),
        C(0.292, 0.541, "Western cave-path Dreaming Glory"),
        C(0.348, 0.584, "Central ridge Dreaming Glory"),
        C(0.3745, 0.6491, "AoA south-central Nagrand herb pin"),
        C(0.431, 0.622, "Central cave-ridge herb"),
        C(0.484, 0.744, "Southern ridge Dreaming Glory"),
        C(0.5035, 0.6023, "AoA central Nagrand herb pin"),
        C(0.5568, 0.5902, "AoA eastern Nagrand herb pin"),
        C(0.604, 0.390, "Eastern raised-ground herb"),
        C(0.762, 0.604, "Eastern mountain-edge herb"),
    },
    confidence = "high",
})

RegisterHerb(22787, "Ragveil", {
    "https://www.wowhead.com/object=181275/ragveil",
    "https://www.wow-professions.com/farming/ragveil-farming",
    "https://warcraft.wiki.gg/wiki/Ragveil",
    "https://artisansofazeroth.com/ragveil-farming-2/",
}, "Zangarmarsh-only herb. It shares the zone with Flame Cap as a rare related spawn, so high-volume Zangarmarsh laps are the practical farm.", {
    id = "ragveil-zangarmarsh-zone-loop",
    source = "Wowhead object map pins and Ragveil farming guides",
    sourceUrls = {
        "https://www.wowhead.com/object=181275/ragveil",
        "https://www.wow-professions.com/farming/ragveil-farming",
        "https://artisansofazeroth.com/ragveil-farming-2/",
    },
    mapName = "Zangarmarsh",
    location = "Full Zangarmarsh herb loop around lakes, marsh edges, and dry paths",
    routeType = "herbalism-loop",
    density = "High",
    dropDifficulty = "Easy but the zone lap is long.",
    tips = {
        "Pick every herb on the loop because Ragveil respawns are spread out.",
        "Watch for Flame Cap as a valuable rare spawn along the same route.",
    },
    coords = {
        C(0.084, 0.539, "Western marsh Ragveil"),
        C(0.174, 0.576, "Northwest marsh Ragveil"),
        C(0.3262, 0.2581, "AoA northwest Zangarmarsh Ragveil route pin"),
        C(0.3422, 0.4088, "AoA west Zangarmarsh Ragveil route pin"),
        C(0.314, 0.635, "Central-west Ragveil"),
        C(0.430, 0.686, "Marsh path Ragveil"),
        C(0.546, 0.689, "Central-east Ragveil"),
        C(0.6902, 0.6690, "AoA east-marsh Ragveil route pin"),
        C(0.592, 0.693, "Eastern marsh Ragveil"),
        C(0.701, 0.758, "Eastern marsh Ragveil"),
        C(0.8646, 0.3365, "AoA Dead Mire Ragveil route pin"),
        C(0.798, 0.843, "Far southeast Ragveil"),
        C(0.842, 0.420, "Dead Mire Ragveil side check"),
    },
    confidence = "high",
})

RegisterHerb(22788, "Flame Cap", {
    "https://www.wowhead.com/object=181276/flame-cap",
    "https://www.wowhead.com/item=22788/flame-cap",
    "https://www.wow-professions.com/farming/ragveil-farming",
    "https://artisansofazeroth.com/ragveil-farming-2/",
}, "Rare Zangarmarsh herb tied to Ragveil routes. Farm Ragveil volume and treat Flame Cap as the valuable bonus.", {
    id = "flame-cap-zangarmarsh-ragveil-route",
    source = "Wowhead object map pins and Outland herb farming guides",
    sourceUrls = {
        "https://www.wowhead.com/object=181276/flame-cap",
        "https://www.wow-professions.com/farming/ragveil-farming",
        "https://artisansofazeroth.com/ragveil-farming-2/",
    },
    mapName = "Zangarmarsh",
    location = "Flame Cap-capable Ragveil nodes across Zangarmarsh",
    routeType = "rare-herb-side-spawn",
    density = "Low",
    dropDifficulty = "Rare. Do not camp a single point; keep the Ragveil route moving.",
    tips = {
        "Use the same path as Ragveil farming.",
        "Compare Flame Cap value against steady Ragveil, Felweed, and fish pool value.",
    },
    coords = {
        C(0.084, 0.539, "Western Flame Cap-capable node"),
        C(0.153, 0.637, "Northwest Flame Cap-capable node"),
        C(0.314, 0.635, "Central Flame Cap-capable node"),
        C(0.592, 0.693, "Eastern Flame Cap-capable node"),
        C(0.743, 0.704, "Southeast Flame Cap-capable node"),
    },
    confidence = "high",
})

RegisterHerb(22789, "Terocone", {
    "https://www.wowhead.com/object=181277/terocone",
    "https://www.wow-professions.com/farming/terocone-farming",
    "https://warcraft.wiki.gg/wiki/Terocone",
    "https://artisansofazeroth.com/terocone-farming/",
}, "Terokkar Forest herb used heavily by Alchemy. Terokkar is the reliable farm; Shadowmoon has too few nodes to target as the main route.", {
    id = "terocone-terokkar-forest-loop",
    source = "Wowhead object map pins and Terocone farming guides",
    sourceUrls = {
        "https://www.wowhead.com/object=181277/terocone",
        "https://www.wow-professions.com/farming/terocone-farming",
        "https://artisansofazeroth.com/terocone-farming/",
    },
    mapName = "Terokkar Forest",
    location = "Outer Terokkar route through roads, forests, hillsides, and open terrain",
    routeType = "herbalism-loop",
    density = "High",
    dropDifficulty = "Good. Flying helps, but many nodes are reachable without it.",
    tips = {
        "Pick every other herb so Terocone nodes have time to respawn.",
        "Skip flying-only Shattrath and Skettis checks if you only want dense Terocone turnover.",
    },
    coords = {
        C(0.166, 0.669, "Western forest Terocone"),
        C(0.252, 0.555, "West-central Terocone"),
        C(0.371, 0.292, "Northern forest Terocone"),
        C(0.6012, 0.2340, "AoA northern Terokkar Terocone route pin"),
        C(0.6563, 0.3070, "AoA northeast Terokkar Terocone pin"),
        C(0.453, 0.614, "Central Terocone"),
        C(0.556, 0.635, "East-central Terocone"),
        C(0.6322, 0.4984, "AoA east-central Terokkar Terocone pin"),
        C(0.688, 0.505, "Eastern forest Terocone"),
        C(0.5797, 0.2645, "AoA north return Terocone pin"),
    },
    confidence = "high",
})

RegisterHerb(22790, "Ancient Lichen", {
    "https://www.wowhead.com/object=181278/ancient-lichen",
    "https://www.wowhead.com/npc=18124/withered-giant",
    "https://www.wow-professions.com/farming/mote-of-life-farming",
}, "Dungeon herb and plant-creature gather. The most useful outdoor anchors are Zangarmarsh bog giants, which Herbalists can gather after looting.", {
    id = "ancient-lichen-zangarmarsh-bog-giants",
    source = "Wowhead object/NPC map pins and Primal Life farming guides",
    sourceUrls = {
        "https://www.wowhead.com/object=181278/ancient-lichen",
        "https://www.wowhead.com/npc=18124/withered-giant",
    },
    mapName = "Zangarmarsh",
    location = "Gatherable bog giant corpses in Dead Mire and Spawning Glen",
    routeType = "herbalism-corpse-route",
    density = "Medium",
    dropDifficulty = "Situational. Best as side value during Primal Life farming.",
    tips = {
        "Loot bog giants first, then gather their corpses with Herbalism.",
        "Do not route only for Ancient Lichen unless the market price beats Primal Life and Ragveil value.",
    },
    coords = {
        C(0.102, 0.620, "Spawning Glen gatherable giant"),
        C(0.136, 0.602, "Western giant corpse route"),
        C(0.782, 0.402, "Dead Mire gatherable giant"),
        C(0.814, 0.432, "Central Dead Mire corpse route"),
        C(0.852, 0.400, "Eastern Dead Mire corpse route"),
    },
    confidence = "medium",
})

RegisterHerb(22791, "Netherbloom", {
    "https://www.wowhead.com/object=181279/netherbloom",
    "https://www.wow-professions.com/farming/netherbloom-farming",
    "https://warcraft.wiki.gg/wiki/Netherbloom",
    "https://artisansofazeroth.com/netherbloom-farming/",
}, "Netherstorm signature herb. It is gathered in open Netherstorm routes and can add Mote of Mana side value.", {
    id = "netherbloom-netherstorm-wide-loop",
    source = "Wowhead object map pins and Netherbloom farming guides",
    sourceUrls = {
        "https://www.wowhead.com/object=181279/netherbloom",
        "https://www.wow-professions.com/farming/netherbloom-farming",
        "https://artisansofazeroth.com/netherbloom-farming/",
    },
    mapName = "Netherstorm",
    location = "Roads, manaforges, ruins, and outer edges across Netherstorm",
    routeType = "herbalism-loop",
    density = "High",
    dropDifficulty = "Good with flying; avoid waiting on single spawns.",
    tips = {
        "Keep a wide route and gather every Netherbloom you see.",
        "Netherbloom can grant random stat buffs and occasional Mote of Mana side gathers.",
        "Combine this with Adamantite and cloud checks if you have Mining or Engineering.",
    },
    coords = {
        C(0.2844, 0.1409, "AoA northern Netherbloom route pin"),
        C(0.194, 0.677, "Northwest Netherbloom"),
        C(0.2863, 0.5317, "AoA western Netherbloom route pin"),
        C(0.277, 0.571, "Western Netherbloom"),
        C(0.342, 0.500, "Central-west Netherbloom"),
        C(0.3519, 0.5462, "AoA central-west Netherbloom pin"),
        C(0.462, 0.605, "Central Netherbloom"),
        C(0.568, 0.567, "Eastern Netherbloom"),
        C(0.5328, 0.1999, "AoA northeast Netherbloom route pin"),
        C(0.638, 0.645, "Far eastern Netherbloom"),
    },
    confidence = "high",
})

RegisterHerb(22792, "Nightmare Vine", {
    "https://www.wowhead.com/object=181280/nightmare-vine",
    "https://www.wow-professions.com/farming/nightmare-vine-farming",
    "https://warcraft.wiki.gg/wiki/Nightmare_Vine",
    "https://artisansofazeroth.com/nightmare-vine-farming-2/",
}, "High-value Outland herb strongly associated with Shadowmoon Valley, with smaller side clusters in Blade's Edge and Hellfire.", {
    id = "nightmare-vine-shadowmoon-valley-loop",
    source = "Wowhead object map pins and Nightmare Vine farming guides",
    sourceUrls = {
        "https://www.wowhead.com/object=181280/nightmare-vine",
        "https://www.wow-professions.com/farming/nightmare-vine-farming",
        "https://artisansofazeroth.com/nightmare-vine-farming-2/",
    },
    mapName = "Shadowmoon Valley",
    location = "Shadowmoon Valley open terrain, rocky edges, Legion Hold, and Netherwing approaches",
    routeType = "herbalism-loop",
    density = "Medium",
    dropDifficulty = "Moderate. It is less dense than common herbs, so gather other nodes along the lap.",
    tips = {
        "Check open ground and rock edges instead of only roads.",
        "Add Legion Hold and Netherwing-side checks when you also want cloth or air motes.",
    },
    coords = {
        C(0.194, 0.229, "Northwest Nightmare Vine"),
        C(0.2491, 0.2984, "AoA northwest Shadowmoon vine route pin"),
        C(0.260, 0.354, "Legion Hold-side vine"),
        C(0.3171, 0.3507, "AoA Legion Hold-side vine pin"),
        C(0.326, 0.444, "West-central Shadowmoon vine"),
        C(0.3851, 0.3015, "AoA north-central Shadowmoon vine pin"),
        C(0.429, 0.610, "Central Shadowmoon vine"),
        C(0.4666, 0.4026, "AoA central Shadowmoon vine pin"),
        C(0.516, 0.316, "Northern Shadowmoon vine"),
        C(0.551, 0.724, "Southern Shadowmoon vine"),
        C(0.612, 0.638, "Netherwing-side vine"),
        C(0.677, 0.534, "Eastern Shadowmoon vine"),
    },
    confidence = "high",
})

RegisterHerb(22793, "Mana Thistle", {
    "https://www.wowhead.com/object=181281/mana-thistle",
    "https://www.wowhead.com/item=22793/mana-thistle",
    "https://warcraft.wiki.gg/wiki/Mana_Thistle",
}, "Rare high-skill Outland herb from flying-access highland areas and Isle of Quel'Danas. Skettis and Twilight Ridge are practical checks.", {
    id = "mana-thistle-terokkar-skettis-highlands",
    source = "Wowhead object map pins and Mana Thistle farming guides",
    sourceUrls = {
        "https://www.wowhead.com/object=181281/mana-thistle",
        "https://www.wowhead.com/item=22793/mana-thistle",
    },
    mapName = "Terokkar Forest",
    location = "High-elevation Terokkar nodes above Shattrath and around Skettis",
    routeType = "rare-herb-highland-loop",
    density = "Low",
    dropDifficulty = "Rare and often camped. Requires high Herbalism and usually flying.",
    tips = {
        "Check Skettis highlands as part of a wider Terokkar herb lap.",
        "Keep moving through highland points rather than camping one node.",
    },
    coords = {
        C(0.202, 0.142, "Northwest highland Mana Thistle"),
        C(0.214, 0.104, "Upper Shattrath highland node"),
        C(0.472, 0.760, "Skettis approach highland node"),
        C(0.613, 0.760, "Skettis west Mana Thistle"),
        C(0.693, 0.746, "Skettis central Mana Thistle"),
        C(0.706, 0.824, "Skettis south return"),
        C(0.749, 0.874, "Skettis southeast Mana Thistle"),
    },
    confidence = "high",
})

Register({
    itemID = 22794,
    itemName = "Fel Lotus",
    expansion = "burningCrusade",
    professions = { "herbalism", "alchemy" },
    category = "Herb",
    researchStatus = "researched",
    sourceUrls = {
        "https://www.wowhead.com/item=22794/fel-lotus",
        "https://warcraft.wiki.gg/wiki/Fel_Lotus",
        "https://www.wowhead.com/object=181280/nightmare-vine",
        "https://www.wowhead.com/npc=18124/withered-giant",
    },
    summary = "Rare Outland herb side gather used for flasks. It is not a standalone node farm; the best approach is to clear high-volume Outland herb routes and gather eligible bog giant corpses.",
    spots = {
        {
            id = "fel-lotus-zangarmarsh-bog-giant-herbing",
            source = "Retail Wowhead item comments, Withered Giant pins, and Warcraft Wiki herb notes",
            sourceUrls = {
                "https://www.wowhead.com/item=22794/fel-lotus",
                "https://www.wowhead.com/npc=18124/withered-giant",
                "https://warcraft.wiki.gg/wiki/Fel_Lotus",
            },
            mapName = "Zangarmarsh",
            location = "Dead Mire and Spawning Glen bog giants, gathered after looting",
            routeType = "rare-herb-side-gather",
            density = "Low for Fel Lotus, medium for Life/Ancient Lichen side value",
            dropDifficulty = "Rare. Kill, loot, and herb-gather eligible bog giant corpses while treating Mote of Life as the steady reward.",
            tips = {
                "Use this route when Fel Lotus, Mote of Life, and Ancient Lichen values all matter.",
                "Keep moving between Dead Mire and Spawning Glen rather than waiting on one corpse cluster.",
            },
            coords = {
                C(0.102, 0.620, "Spawning Glen herbable giant"),
                C(0.136, 0.602, "Western giant corpse route"),
                C(0.782, 0.402, "Dead Mire herbable giant"),
                C(0.814, 0.432, "Central Dead Mire corpse route"),
                C(0.852, 0.400, "Eastern Dead Mire corpse route"),
            },
            confidence = "medium",
        },
        {
            id = "fel-lotus-shadowmoon-nightmare-vine-route",
            source = "Retail Wowhead item comments and Nightmare Vine object map pins",
            sourceUrls = {
                "https://www.wowhead.com/item=22794/fel-lotus",
                "https://www.wowhead.com/object=181280/nightmare-vine",
            },
            mapName = "Shadowmoon Valley",
            location = "Nightmare Vine and mixed-herb route through Shadowmoon Valley",
            routeType = "rare-herb-side-gather",
            density = "Low for Fel Lotus, medium for Nightmare Vine",
            dropDifficulty = "Rare. Pick every Outland herb on the lap; Fel Lotus is the bonus, not the route's baseline.",
            tips = {
                "Use this when Nightmare Vine is already profitable.",
                "Netherwing-side checks can also feed daily/rep movement if relevant.",
            },
            coords = {
                C(0.194, 0.229, "Northwest Nightmare Vine Fel Lotus check"),
                C(0.260, 0.354, "Legion Hold-side herb check"),
                C(0.429, 0.610, "Central Shadowmoon herb check"),
                C(0.551, 0.724, "Southern Shadowmoon herb check"),
                C(0.612, 0.638, "Netherwing-side herb check"),
                C(0.677, 0.534, "Eastern Shadowmoon herb check"),
            },
            confidence = "medium",
        },
    },
})

AppendCatalogHerbSpot(22787, CatalogHerbSpot(
    "ragveil-zangarmarsh-golden-routes-main",
    {
        "https://www.wowhead.com/object=181275/ragveil",
        "https://www.wow-professions.com/farming/ragveil-farming",
        "https://artisansofazeroth.com/ragveil-farming-2/",
    },
    "Zangarmarsh",
    "Golden Routes eastern Zangarmarsh Ragveil circuit",
    "High for Ragveil",
    "Easy. The route is concentrated on the eastern half of Zangarmarsh.",
    {
        "Use this as the main Ragveil loop when you want a tighter route than the full-zone lap.",
        "Gather Flame Cap when it appears on the same Ragveil-capable circuit.",
    },
    RAGVEIL_ZANGARMARSH_MAIN_COORDS
))

AppendCatalogHerbSpot(22787, CatalogHerbSpot(
    "ragveil-zangarmarsh-golden-routes-alt",
    {
        "https://www.wowhead.com/object=181275/ragveil",
        "https://www.wow-professions.com/farming/ragveil-farming",
        "https://artisansofazeroth.com/ragveil-farming-2/",
    },
    "Zangarmarsh",
    "Smaller Golden Routes Zangarmarsh Ragveil alternative loop",
    "Medium to high",
    "Easy. Compact alternative when the main eastern circuit is crowded.",
    {
        "Use this as a short alternate loop around the eastern Ragveil clusters.",
        "Works as a Flame Cap check because Flame Cap rides the same Zangarmarsh herb movement.",
    },
    RAGVEIL_ZANGARMARSH_ALT_COORDS
))

AppendCatalogHerbSpot(22787, CatalogHerbSpot(
    "ragveil-zangarmarsh-catalog-mixed-herb-route",
    {
        "https://www.wowhead.com/object=181275/ragveil",
        "https://www.wow-professions.com/farming/ragveil-farming",
        "https://www.wowhead.com/object=181276/flame-cap",
    },
    "Zangarmarsh",
    "Hidden Catalog mixed-herb Zangarmarsh route for Ragveil and Flame Cap checks",
    "High for mixed Zangarmarsh herbs",
    "Good broad route. It is longer than the compact Golden Routes loops.",
    {
        "Use this when you want wider Zangarmarsh coverage.",
        "The supplied route note reported strong Ragveil and Flame Cap results from this loop.",
    },
    ZANGARMARSH_MIXED_HERB_COORDS
))

AppendCatalogHerbSpot(22788, CatalogHerbSpot(
    "flame-cap-zangarmarsh-ragveil-main-route",
    {
        "https://www.wowhead.com/object=181276/flame-cap",
        "https://www.wowhead.com/item=22788/flame-cap",
        "https://www.wow-professions.com/farming/ragveil-farming",
    },
    "Zangarmarsh",
    "Golden Routes eastern Ragveil circuit used for Flame Cap side spawns",
    "Low for Flame Cap, high for Ragveil",
    "Rare. Keep farming Ragveil volume and treat Flame Cap as the bonus.",
    {
        "Do not camp one point; run the full eastern circuit.",
        "Use this when Flame Cap prices justify staying in Zangarmarsh.",
    },
    RAGVEIL_ZANGARMARSH_MAIN_COORDS,
    "rare-herb-side-spawn"
))

AppendCatalogHerbSpot(22788, CatalogHerbSpot(
    "flame-cap-zangarmarsh-ragveil-alt-route",
    {
        "https://www.wowhead.com/object=181276/flame-cap",
        "https://www.wowhead.com/item=22788/flame-cap",
        "https://www.wow-professions.com/farming/ragveil-farming",
    },
    "Zangarmarsh",
    "Compact Golden Routes Ragveil alternative used for Flame Cap side spawns",
    "Low for Flame Cap, medium for Ragveil",
    "Rare. Smaller loop for repeated Flame Cap-capable Ragveil checks.",
    {
        "Use this shorter route when the larger eastern loop feels too slow.",
        "Keep picking Ragveil to maintain route value between rare Flame Cap finds.",
    },
    RAGVEIL_ZANGARMARSH_ALT_COORDS,
    "rare-herb-side-spawn"
))

AppendCatalogHerbSpot(22788, CatalogHerbSpot(
    "flame-cap-zangarmarsh-catalog-mixed-herb-route",
    {
        "https://www.wowhead.com/object=181276/flame-cap",
        "https://www.wowhead.com/item=22788/flame-cap",
        "https://www.wowhead.com/object=181275/ragveil",
    },
    "Zangarmarsh",
    "Hidden Catalog mixed-herb Zangarmarsh route used for Flame Cap side checks",
    "Low for Flame Cap, high for Ragveil",
    "Rare. Best evaluated as part of a high-volume Ragveil route.",
    {
        "The supplied route note reported Flame Cap results alongside Ragveil.",
        "Use the wider Catalog route when the compact Golden Routes alternatives are crowded.",
    },
    ZANGARMARSH_MIXED_HERB_COORDS,
    "rare-herb-side-spawn"
))

AppendCatalogHerbSpot(22790, CatalogHerbSpot(
    "ancient-lichen-zangarmarsh-catalog-bog-lord-proxy",
    {
        "https://www.wowhead.com/object=181278/ancient-lichen",
        "https://www.wowhead.com/npc=18124/withered-giant",
        "https://www.wow-professions.com/farming/mote-of-life-farming",
    },
    "Zangarmarsh",
    "Catalog Zangarmarsh mixed-herb route used as an outdoor Ancient Lichen proxy through herbable bog lords",
    "Situational",
    "Ancient Lichen is not a normal outdoor node route; use this as a proxy while farming herbable plant creatures.",
    {
        "Kill and loot eligible bog giants before using Herbalism on their corpses.",
        "Treat Ragveil, Flame Cap, and Primal Life side value as the steady part of the route.",
    },
    ZANGARMARSH_MIXED_HERB_COORDS,
    "herbalism-corpse-route",
    "medium"
))

AppendCatalogHerbSpot(22789, CatalogHerbSpot(
    "terocone-terokkar-golden-routes-compact-alt",
    {
        "https://www.wowhead.com/object=181277/terocone",
        "https://www.wow-professions.com/farming/terocone-farming",
        "https://artisansofazeroth.com/terocone-farming/",
    },
    "Terokkar Forest",
    "Compact Golden Routes targeted Terocone circuit",
    "High for a compact loop",
    "Good. Shorter than the full Terokkar herb route and easier to repeat.",
    {
        "Use this route when Terocone is the main target.",
        "Gather other herbs on the path to keep node turnover moving.",
    },
    TEROCONE_TEROKKAR_COMPACT_COORDS
))

AppendCatalogHerbSpot(22789, CatalogHerbSpot(
    "terocone-terokkar-searchforloot-main",
    {
        "https://www.wowhead.com/object=181277/terocone",
        "https://www.wow-professions.com/farming/terocone-farming",
        "https://www.wowhead.com/object=181281/mana-thistle",
    },
    "Terokkar Forest",
    "SearchForLoot-tested high-density Terokkar Forest herb route",
    "Very high for Terocone",
    "Strong. Supplied notes reported about 120.6 Terocone per hour on this exact retail import route.",
    {
        "Use this as the main Terocone route when you also value Mana Thistle and Fel Lotus.",
        "The route is long, but it covers the dense Terokkar herb network thoroughly.",
    },
    TEROKKAR_HERBS_MAIN_COORDS
))

AppendCatalogHerbSpot(22793, CatalogHerbSpot(
    "mana-thistle-terokkar-searchforloot-main",
    {
        "https://www.wowhead.com/object=181281/mana-thistle",
        "https://www.wowhead.com/item=22793/mana-thistle",
        "https://www.wowhead.com/object=181277/terocone",
    },
    "Terokkar Forest",
    "SearchForLoot-tested Terokkar herb route with Mana Thistle side results",
    "Low for Mana Thistle, high for Terocone",
    "Rare side herb. Supplied notes reported about 7 Mana Thistle per hour while farming this route.",
    {
        "Use this when Mana Thistle value is high but Terocone still carries the route.",
        "Do not skip Terocone; it is the volume material on this path.",
    },
    TEROKKAR_HERBS_MAIN_COORDS,
    "rare-herb-highland-loop"
))

AppendCatalogHerbSpot(22794, CatalogHerbSpot(
    "fel-lotus-terokkar-searchforloot-main",
    {
        "https://www.wowhead.com/item=22794/fel-lotus",
        "https://www.wowhead.com/object=181277/terocone",
        "https://www.wowhead.com/object=181281/mana-thistle",
    },
    "Terokkar Forest",
    "SearchForLoot-tested Terokkar herb route with measured Fel Lotus side value",
    "Low for Fel Lotus, very high for eligible herb volume",
    "Rare side gather. Supplied notes reported about 4.6 Fel Lotus per hour on this exact retail import route.",
    {
        "This is the strongest supplied Fel Lotus route because it has measured results.",
        "Treat Terocone and Mana Thistle as the route value between rare Fel Lotus gathers.",
    },
    TEROKKAR_HERBS_MAIN_COORDS,
    "rare-herb-side-gather",
    "high"
))

AppendCatalogHerbSpot(22791, CatalogHerbSpot(
    "netherbloom-netherstorm-xscarlife-main",
    {
        "https://www.wowhead.com/object=181279/netherbloom",
        "https://www.wow-professions.com/farming/netherbloom-farming",
        "https://artisansofazeroth.com/netherbloom-farming/",
    },
    "Netherstorm",
    "Retail-native xScarlife Netherstorm Netherbloom route",
    "High",
    "Good with flying. The route crosses several islands and manaforge edges.",
    {
        "Use this as the main Netherbloom route.",
        "Gather every Netherbloom node to keep replacement spawns moving.",
    },
    NETHERBLOOM_NETHERSTORM_MAIN_COORDS
))

AppendCatalogHerbSpot(22791, CatalogHerbSpot(
    "netherbloom-netherstorm-catalog-mixed-alt",
    {
        "https://www.wowhead.com/object=181279/netherbloom",
        "https://www.wow-professions.com/farming/netherbloom-farming",
        "https://www.wowhead.com/object=181281/mana-thistle",
    },
    "Netherstorm",
    "Hidden Catalog Netherstorm mixed-herb route",
    "Medium to high",
    "Alternative loop. Supplied notes reported Netherbloom and Mana Thistle together.",
    {
        "Use this as a backup when the main Netherbloom route is crowded.",
        "It is also useful when Mana Thistle prices make side checks valuable.",
    },
    NETHERSTORM_MIXED_HERB_COORDS
))

AppendCatalogHerbSpot(22793, CatalogHerbSpot(
    "mana-thistle-netherstorm-catalog-mixed-alt",
    {
        "https://www.wowhead.com/object=181281/mana-thistle",
        "https://www.wowhead.com/item=22793/mana-thistle",
        "https://www.wowhead.com/object=181279/netherbloom",
    },
    "Netherstorm",
    "Hidden Catalog Netherstorm mixed-herb route with Mana Thistle results",
    "Low for Mana Thistle, medium to high for Netherbloom",
    "Rare side herb. Supplied notes reported 22 Mana Thistle in the route results.",
    {
        "Use this as a Mana Thistle side route while Netherbloom carries steady value.",
        "The route makes more sense with flying because Netherstorm has separated landmasses.",
    },
    NETHERSTORM_MIXED_HERB_COORDS,
    "rare-herb-highland-loop",
    "medium"
))

AppendCatalogHerbSpot(22794, CatalogHerbSpot(
    "fel-lotus-netherstorm-catalog-mixed-alt",
    {
        "https://www.wowhead.com/item=22794/fel-lotus",
        "https://www.wowhead.com/object=181279/netherbloom",
        "https://www.wowhead.com/object=181281/mana-thistle",
    },
    "Netherstorm",
    "Hidden Catalog Netherstorm mixed-herb route for Fel Lotus-eligible herb volume",
    "Low for Fel Lotus, medium to high for eligible herbs",
    "Rare side gather. Best used when Netherbloom and Mana Thistle also sell well.",
    {
        "Use this as a secondary Fel Lotus route, behind the measured Terokkar herb loop.",
        "Keep the route moving rather than camping a single herb spawn.",
    },
    NETHERSTORM_MIXED_HERB_COORDS,
    "rare-herb-side-gather",
    "medium"
))

AppendCatalogHerbSpot(22792, CatalogHerbSpot(
    "nightmare-vine-shadowmoon-golden-routes-main",
    {
        "https://www.wowhead.com/object=181280/nightmare-vine",
        "https://www.wow-professions.com/farming/nightmare-vine-farming",
        "https://artisansofazeroth.com/nightmare-vine-farming-2/",
    },
    "Shadowmoon Valley",
    "Golden Routes Shadowmoon Valley Nightmare Vine circuit",
    "High for Nightmare Vine",
    "Strong dedicated route. Shadowmoon remains the best direct Nightmare Vine zone.",
    {
        "Use this as the main Nightmare Vine route.",
        "Gather other Outland herbs along the loop when Fel Lotus side value matters.",
    },
    NIGHTMARE_VINE_SHADOWMOON_COORDS
))

AppendCatalogHerbSpot(22794, CatalogHerbSpot(
    "fel-lotus-shadowmoon-nightmare-vine-import",
    {
        "https://www.wowhead.com/item=22794/fel-lotus",
        "https://www.wowhead.com/object=181280/nightmare-vine",
        "https://www.wow-professions.com/farming/nightmare-vine-farming",
    },
    "Shadowmoon Valley",
    "Golden Routes Nightmare Vine circuit used for Fel Lotus side gathers",
    "Low for Fel Lotus, high for Nightmare Vine",
    "Rare side gather. Use when Nightmare Vine price makes Shadowmoon worth farming.",
    {
        "Fel Lotus is a rare side gather, not a standalone node route.",
        "This route is best for Fel Lotus when Nightmare Vine is also profitable.",
    },
    NIGHTMARE_VINE_SHADOWMOON_COORDS,
    "rare-herb-side-gather",
    "medium"
))

AppendCatalogHerbSpot(22785, SuppliedHerbRoute(
    "felweed-blades-edge-supplied-main",
    105,
    "Blade's Edge Mountains",
    "Main - Blade's Edge plateau circuit",
    SUPPLIED_BLADES_EDGE_COMMON,
    { XSCARLIFE_ROUTES, FELWEED_GUIDE },
    {
        "Blade's Edge is one of the strongest Felweed zones because its outdoor herb pool contains substantial Felweed and Dreaming Glory.",
        "Follow accessible plateaus instead of repeatedly diving into ravines.",
        "Collect Dreaming Glory and Nightmare Vine too; clearing shared herb locations improves Felweed turnover.",
        "Flight is strongly recommended because of the vertical terrain.",
    },
    "High Felweed and Dreaming Glory turnover",
    "Moderate because of vertical terrain"
))

AppendCatalogHerbSpot(22785, SuppliedHerbRoute(
    "felweed-nagrand-supplied-alternative",
    107,
    "Nagrand",
    "Alternative - broad Nagrand perimeter",
    SUPPLIED_FELWEED_NAGRAND_ALT,
    { XSCARLIFE_ROUTES, FELWEED_GUIDE },
    {
        "Nagrand has easier terrain and sightlines than Blade's Edge.",
        "Check around hills, cliffs, elemental areas, and the edges of settlement regions.",
        "Do not cross the empty center unnecessarily; maintain a broad outer circuit.",
        "Use this alternative when Blade's Edge is being farmed.",
    },
    "High for common Outland herbs",
    "Easy flying circuit"
))

AppendCatalogHerbSpot(22786, SuppliedHerbRoute(
    "dreaming-glory-blades-edge-supplied-main",
    105,
    "Blade's Edge Mountains",
    "Main - Blade's Edge cliff and plateau circuit",
    SUPPLIED_BLADES_EDGE_COMMON,
    { XSCARLIFE_ROUTES, FELWEED_GUIDE },
    {
        "Search cliff ledges and elevated terrain; Dreaming Glory strongly favors rocky features.",
        "Fly close enough to the terrain for tracking to register nodes above and below you.",
        "Pick Felweed encountered along the loop to recycle the herb pool.",
        "Avoid flying through canyon centers while ignoring the ledges.",
    },
    "High on rocky and elevated terrain",
    "Moderate because elevation can hide nodes"
))

AppendCatalogHerbSpot(22786, SuppliedHerbRoute(
    "dreaming-glory-nagrand-supplied-alternative",
    107,
    "Nagrand",
    "Alternative - Nagrand hills and outer walls",
    SUPPLIED_DREAMING_GLORY_NAGRAND_ALT,
    { XSCARLIFE_ROUTES, FELWEED_GUIDE },
    {
        "Concentrate on raised hills, broken rock formations, and outer mountain walls.",
        "Nagrand is faster and less demanding than Blade's Edge but can have more competition.",
        "Clear Felweed as you go instead of cherry-picking.",
    },
    "High for mixed common herbs",
    "Easy flying circuit"
))

AppendCatalogHerbSpot(22787, SuppliedHerbRoute(
    "ragveil-zangarmarsh-supplied-main",
    102,
    "Zangarmarsh",
    "Main - full Zangarmarsh circuit",
    SUPPLIED_RAGVEIL_MAIN,
    { XSCARLIFE_ROUTES, "https://www.wow-professions.com/farming/ragveil-farming" },
    {
        "Ragveil is strongly associated with Zangarmarsh's open marsh terrain.",
        "Stay low around mushroom bases, pools, islands, and dry strips between wetlands.",
        "Pick Flame Cap and Felweed too so the shared nodes keep cycling.",
        "The route is deliberately long enough to reduce waiting for respawns.",
    },
    "High across open marsh terrain",
    "Easy but intentionally long"
))

AppendCatalogHerbSpot(22787, SuppliedHerbRoute(
    "ragveil-terokkar-supplied-alternative",
    108,
    "Terokkar Forest",
    "Alternative - northern and western forest circuit",
    SUPPLIED_TEROKKAR_FOREST,
    { XSCARLIFE_ROUTES, "https://www.wow-professions.com/farming/ragveil-farming" },
    {
        "This is a mixed-herb fallback rather than a specialized Ragveil circuit.",
        "Stay primarily in the greener northern and western portions.",
        "Expect Terocone and Felweed alongside Ragveil.",
        "Use it when Zangarmarsh is crowded or phased poorly.",
    },
    "Medium mixed-herb density",
    "Easy fallback route"
))

AppendCatalogHerbSpot(22788, SuppliedHerbRoute(
    "flame-cap-zangarmarsh-supplied-main",
    102,
    "Zangarmarsh",
    "Main - western and southern Zangarmarsh circuit",
    SUPPLIED_FLAME_CAP_MAIN,
    { XSCARLIFE_ROUTES, "https://www.wow-professions.com/farming/ragveil-farming" },
    {
        "Flame Cap is a rare Zangarmarsh spawn rather than a high-density standalone herb.",
        "Gather every Ragveil and Felweed node; cherry-picking can leave available herb locations occupied.",
        "Make several laps before judging the route because Flame Cap's share of the pool is low.",
        "Continuously clearing the local herb pool is more dependable than realm hopping.",
    },
    "Low for Flame Cap, high for supporting herbs",
    "Rare and RNG-dependent",
    "rare-herb-side-spawn"
))

AppendCatalogHerbSpot(22788, SuppliedHerbRoute(
    "flame-cap-zangarmarsh-supplied-alternative",
    102,
    "Zangarmarsh",
    "Alternative - eastern and central Zangarmarsh circuit",
    SUPPLIED_FLAME_CAP_ALT,
    { XSCARLIFE_ROUTES, "https://www.wow-professions.com/farming/ragveil-farming" },
    {
        "Use this shorter loop if western Zangarmarsh appears depleted.",
        "Search around mushroom clusters and small raised islands rather than flying high over them.",
        "Alternate between the two Zangarmarsh routes to allow node regeneration.",
    },
    "Low for Flame Cap, medium for supporting herbs",
    "Rare but compact",
    "rare-herb-side-spawn"
))

AppendCatalogHerbSpot(22789, SuppliedHerbRoute(
    "terocone-terokkar-supplied-main",
    108,
    "Terokkar Forest",
    "Main - general-purpose Terokkar Forest circuit",
    SUPPLIED_TEROKKAR_FOREST,
    { XSCARLIFE_ROUTES, "https://www.wow-professions.com/farming/terocone-farming" },
    {
        "This is the best general-purpose Terocone route in the supplied set.",
        "Follow tree lines, forest edges, hills, and ruins.",
        "Give the heavily corrupted southeastern wasteland less attention.",
        "Pick Felweed and Ragveil so new Terocone has opportunities to spawn.",
    },
    "High for Terocone",
    "Easy general-purpose route"
))

AppendCatalogHerbSpot(22789, SuppliedHerbRoute(
    "terocone-shadowmoon-supplied-alternative",
    104,
    "Shadowmoon Valley",
    "Alternative - Shadowmoon mixed-herb circuit",
    SUPPLIED_SHADOWMOON,
    { XSCARLIFE_ROUTES, "https://www.wow-professions.com/farming/terocone-farming" },
    {
        "Treat this as a mixed-herb alternative; Nightmare Vine will dominate parts of the circuit.",
        "Search the greener western and central areas more carefully than barren lava sections.",
        "Use it when Terokkar is crowded or when you also need Nightmare Vine.",
    },
    "Medium mixed-herb density",
    "Moderate alternative route"
))

AppendCatalogHerbSpot(22790, SuppliedHerbRoute(
    "ancient-lichen-slave-pens-supplied-main",
    260,
    "The Slave Pens",
    "Main - Slave Pens interior herb route",
    SUPPLIED_SLAVE_PENS,
    { XSCARLIFE_ROUTES, "https://www.wowhead.com/object=181278/ancient-lichen" },
    {
        "Ancient Lichen grows inside Outland dungeons rather than on normal outdoor circuits.",
        "Clear on Normal for easy solo resets.",
        "Check walls, tunnel sides, rock shelves, and damp corners.",
        "The route overlay may require opening the instance map once after entering.",
    },
    "Localized dungeon herb nodes",
    "Easy solo clear with instance reset limits",
    "dungeon-herbalism-loop"
))

AppendCatalogHerbSpot(22790, SuppliedHerbRoute(
    "ancient-lichen-underbog-supplied-alternative",
    262,
    "The Underbog",
    "Alternative - Underbog interior herb route",
    SUPPLIED_UNDERBOG,
    { XSCARLIFE_ROUTES, "https://www.wowhead.com/object=181278/ancient-lichen" },
    {
        "The Underbog is longer but provides more extensive wall and plant-covered terrain.",
        "Use a class with strong movement speed and instant area damage.",
        "Reset after completing the useful herb section rather than always clearing every boss.",
        "Respect Retail's per-hour instance-entry limit.",
    },
    "Localized dungeon herb nodes",
    "Longer solo clear with instance reset limits",
    "dungeon-herbalism-loop"
))

AppendCatalogHerbSpot(22791, SuppliedHerbRoute(
    "netherbloom-netherstorm-supplied-main",
    109,
    "Netherstorm",
    "Main - full Netherstorm circuit",
    SUPPLIED_NETHERSTORM_MAIN,
    { XSCARLIFE_ROUTES, "https://www.wow-professions.com/farming/netherbloom-farming" },
    {
        "Netherbloom is the dominant outdoor herb in Netherstorm.",
        "Circle individual landmasses rather than flying straight across the Twisting Nether.",
        "Scan around eco-domes, mana forges, rock edges, and settlement perimeters.",
        "The full circuit is long enough for nodes near the beginning to start recycling.",
    },
    "High",
    "Easy with flying"
))

AppendCatalogHerbSpot(22791, SuppliedHerbRoute(
    "netherbloom-netherstorm-supplied-alternative",
    109,
    "Netherstorm",
    "Alternative - compact central and southern circuit",
    SUPPLIED_NETHERSTORM_ALT,
    { XSCARLIFE_ROUTES, "https://www.wow-professions.com/farming/netherbloom-farming" },
    {
        "Use this faster route to test current node density.",
        "If you begin catching your own respawn gap, switch to the full route.",
        "Avoid long detours to isolated islands unless tracking shows a node.",
    },
    "Medium to high",
    "Easy compact route"
))

AppendCatalogHerbSpot(22792, SuppliedHerbRoute(
    "nightmare-vine-shadowmoon-supplied-main",
    104,
    "Shadowmoon Valley",
    "Main - Shadowmoon Valley circuit",
    SUPPLIED_SHADOWMOON,
    { XSCARLIFE_ROUTES, "https://www.wow-professions.com/farming/nightmare-vine-farming" },
    {
        "Shadowmoon Valley is the primary Nightmare Vine farming zone.",
        "Follow terrain edges, lava-field boundaries, ridges, and fel-corrupted areas.",
        "Stay relatively close to the ground because elevation differences can hide nodes.",
        "Collect other visible herbs to prevent the local spawn pool from stagnating.",
    },
    "High for Nightmare Vine",
    "Moderate because elevation can hide nodes"
))

AppendCatalogHerbSpot(22792, SuppliedHerbRoute(
    "nightmare-vine-blades-edge-supplied-alternative",
    105,
    "Blade's Edge Mountains",
    "Alternative - Blade's Edge mixed-herb circuit",
    SUPPLIED_NIGHTMARE_VINE_ALT,
    { XSCARLIFE_ROUTES, "https://www.wow-professions.com/farming/nightmare-vine-farming" },
    {
        "Nightmare Vine is less concentrated here than in Shadowmoon Valley.",
        "Use this as a mixed Felweed, Dreaming Glory, and Nightmare Vine route.",
        "Prioritize fel-corrupted sections and higher-level subzones.",
    },
    "Medium mixed-herb density",
    "Moderate alternative route"
))

AppendCatalogHerbSpot(22793, SuppliedHerbRoute(
    "mana-thistle-blades-edge-supplied-main",
    105,
    "Blade's Edge Mountains",
    "Main - high plateaus circuit",
    SUPPLIED_MANA_THISTLE_MAIN,
    { XSCARLIFE_ROUTES, "https://www.wowhead.com/object=181281/mana-thistle" },
    {
        "Mana Thistle favors higher-level areas and elevated plateaus.",
        "Check Ogri'la, Forge Camp regions, and the upper plateaus carefully.",
        "Do not rely exclusively on the generic lowland Felweed loop; Mana Thistle's distribution is more restricted.",
        "Flying is effectively mandatory for an efficient circuit.",
    },
    "Low and geographically restricted",
    "Hard without fast flying",
    "rare-herb-highland-loop"
))

AppendCatalogHerbSpot(22793, SuppliedHerbRoute(
    "mana-thistle-skettis-supplied-alternative",
    108,
    "Terokkar Forest",
    "Alternative - compact Skettis circuit",
    SUPPLIED_MANA_THISTLE_ALT,
    { XSCARLIFE_ROUTES, "https://www.wowhead.com/object=181281/mana-thistle" },
    {
        "This compact route targets Skettis rather than the entire Terokkar map.",
        "Search islands, tree bases, ruins, and elevated edges.",
        "The circuit is short; pause briefly or alternate zones if nodes have not respawned.",
        "Avoid spending excessive time fighting mobs; Retail characters should disengage quickly.",
    },
    "Low and compact",
    "Moderate because the circuit can outrun respawns",
    "rare-herb-highland-loop"
))

AppendCatalogHerbSpot(22794, SuppliedHerbRoute(
    "fel-lotus-netherstorm-supplied-main",
    109,
    "Netherstorm",
    "Main - Netherbloom proxy circuit",
    SUPPLIED_NETHERSTORM_MAIN,
    { XSCARLIFE_ROUTES, "https://www.wowhead.com/item=22794/fel-lotus" },
    {
        "Optimize total herbs gathered per hour rather than searching for a visible Fel Lotus node.",
        "Netherstorm's abundant Netherbloom makes it a strong proxy.",
        "Never skip normal herb nodes; each gathering attempt is another Fel Lotus chance.",
        "Track results over several hundred nodes because short sessions are heavily affected by luck.",
    },
    "Rare bonus from high eligible-herb volume",
    "RNG-dependent",
    "rare-herb-side-gather"
))

AppendCatalogHerbSpot(22794, SuppliedHerbRoute(
    "fel-lotus-shadowmoon-supplied-alternative",
    104,
    "Shadowmoon Valley",
    "Alternative - Nightmare Vine proxy circuit",
    SUPPLIED_SHADOWMOON,
    { XSCARLIFE_ROUTES, "https://www.wowhead.com/item=22794/fel-lotus" },
    {
        "Use this route when Netherstorm is depleted or heavily contested.",
        "Gather every Nightmare Vine and other Outland herb encountered.",
        "This route gains value when Nightmare Vine itself sells better on your realm.",
        "Fel Lotus results remain RNG-dependent regardless of route.",
    },
    "Rare bonus from mixed Outland herbs",
    "RNG-dependent",
    "rare-herb-side-gather"
))

AppendCatalogHerbSpot(22792, CatalogHerbSpot(
    "nightmare-vine-blades-edge-catalog-alt",
    {
        "https://www.wowhead.com/object=181280/nightmare-vine",
        "https://www.wow-professions.com/farming/nightmare-vine-farming",
    },
    "Blade's Edge Mountains",
    "Hidden Catalog Blade's Edge Mountains circuit used as a Nightmare Vine alternative",
    "Medium",
    "Alternative route. Supplied notes reported Nightmare Vine despite the original route name being Dreaming Glory.",
    {
        "Use this when Shadowmoon Valley is heavily farmed.",
        "Treat Dreaming Glory and other herbs as side value while checking Nightmare Vine-capable areas.",
    },
    NIGHTMARE_VINE_BLADES_EDGE_COORDS,
    "herbalism-loop",
    "medium"
))
