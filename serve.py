from fastapi import FastAPI
from autogluon.timeseries import TimeSeriesPredictor, TimeSeriesDataFrame
import pandas as pd
from pyhive import hive
import uvicorn  # Required to run the server


app = FastAPI()
predictor = TimeSeriesPredictor.load(
    "model",
    require_version_match=False
)

def get_recent_data(city: str, forecast_length: int = 16):
    """Retrieve last 72 hours of data from Hive"""
    conn = hive.Connection(host="127.0.0.1", port=10000)
    query = f"""
        SELECT 
            *
        FROM train_data_1
        WHERE city = '{city}'
        ORDER BY ts DESC
        LIMIT {forecast_length}
    """
    df = pd.read_sql(query, conn)
    df.columns = df.columns.str.replace(r'^.*?\.', '', regex=True)
    df['ts'] = df['ts'] * 10 ** 9
    return df

def get_future_known_covariates(city: str, prediction_length: int = 12):
    """Generate future known covariates for the forecast horizon"""
    # Get the latest timestamp from recent data
    recent_data = get_recent_data(city)
    last_timestamp = recent_data["ts"].max()
    future_dates = pd.date_range(
        start=pd.to_datetime(last_timestamp, unit='ns') + pd.Timedelta(days=1),
        periods=prediction_length,
        freq='D'
    )
    known_covariates_names=[
        'temperature_avg', 'dew_point_avg', 'wind_speed_avg', 'max_wind_speed_max', 'gust_avg',
        'temp_wind_interaction', 'precip_accum_72h'
    ]
    
    # Create DataFrame with required known covariates (replace with your actual covariates)
    known_covariates = pd.DataFrame({
        "city": [city] * prediction_length,
        "ts": future_dates.astype('int64'),
        # # Include all columns from predictor.known_covariates_names here
        # "temperature": [25.0] * prediction_length,  # Example covariate
        # "humidity": [60.0] * prediction_length       # Example covariate
    })
    for col in known_covariates_names:
        known_covariates[col] = .0
    return known_covariates
@app.get("/forecast1/{city}")
async def predict_aqi1(city: str):
    forecast_length = 12
    recent_data = get_recent_data(city, forecast_length)
    known_covariates_names=[
        'city', 'ts', 'value', 'temperature_avg', 'dew_point_avg', 'wind_speed_avg', 'max_wind_speed_max', 'gust_avg',
        'temp_wind_interaction', 'precip_accum_72h'
    ]
    # recent_data.columns = recent_data.columns.str.replace(' train_data_1.', '', regex=False)
    ts_dataframe = TimeSeriesDataFrame.from_data_frame(
        recent_data,
        id_column="city",
        timestamp_column="ts",
    )

    known_covariates = recent_data[known_covariates_names]
    known_covariates_tsdf = TimeSeriesDataFrame.from_data_frame(
        known_covariates,
        id_column="city",
        timestamp_column="ts",
    )


    forecast = predictor.predict(ts_dataframe, known_covariates=known_covariates_tsdf)
    return {
        "city": city,
        "forecast": forecast.mean.tolist(),
        "confidence_interval": {
            "0.1": forecast.quantile(0.1).tolist(),
            "0.9": forecast.quantile(0.9).tolist()
        }
    }

@app.get("/forecast/{city}")

async def predict_aqi(city: str):
    recent_data = get_recent_data(city)
    
    # Convert to TimeSeriesDataFrame
    ts_dataframe = TimeSeriesDataFrame.from_data_frame(
        recent_data,
        id_column="city",
        timestamp_column="ts",
    )
    
    # Get future known covariates
    future_covariates = get_future_known_covariates(city)
    future_covariates_tsdf = TimeSeriesDataFrame.from_data_frame(
        future_covariates,
        id_column="city",
        timestamp_column="ts",
    )
    
    # Make prediction with known covariates
    forecast = predictor.predict(
        ts_dataframe,
        known_covariates=future_covariates_tsdf
    )
    return {
        "city": city,
        "forecast": list(forecast['mean']),
        "confidence_interval": {
            "0.1": list(forecast.quantile(0.1)),
            "0.9": list(forecast.quantile(0.9))
        }
    }

uvicorn.run(app, host="0.0.0.0", port=8000)
