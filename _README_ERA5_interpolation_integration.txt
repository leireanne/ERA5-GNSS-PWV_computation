This folders contains the scripts to compute ERA5 and GNSS PWV.
Leire Retegui Schiettekatte. AAU Geodesy 2023.
%_________________________________________________________________

INPUT FOR THE SCRIPTS
- ERA5 pressure level data on
	- Geopotential
	- Temperature
	- Specific humidity
- GNSS ZTD time series.
- GNSS station coordinates and ellipsoidal height.
- GNSS orthometric height.

%_________________________________________________________________

WORKFLOW
1) A01_MAIN_load_ERA5_data_compute_Tm_PWV
	Computes ERA5 PWV and Tm using ERA5 pressure level data.
2) C02_MAIN_compare_ERA5_GNSS_p__t.
	Compares the pressure and mean temperature obtained by ERA5 with
	the original time series computed in 2022.
3) A02_MAIN_compute_GNSS_PWV
	Computes GNSS-PWV using ERA5 pressure and Tm and GNSS ZTD.
4) C02_MAIN_compare_ERA5_GNSS_PWV
	Compares the PWV obtained using only ERA5 model with the PWV obtained 
	using GNSS-ZTD + ERA5-P-Tm.

%________________________________________________________________

OUTPUT
- ERA5 pressure time series.
- ERA5 mean temperature time series.
- ERA5 integrated PWV time series.
- GNSS-ERA5-PWV time series.

%________________________________________________________________

