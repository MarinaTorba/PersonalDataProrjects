import streamlit as st
import pandas as pd
import numpy as np

# Ruta del archivo CSV
df = pd.read_csv(r'C:\Users\Albert\ProjecteData\Equip_G\Data\2025_04_10_Sprint01.csv')

# KPI 1: Tasa de ocupación calculada utilizando availability_30
df['tasa_ocupacion'] = ((30 - df['availability_30']) / 30) * 100  # Fórmula correcta

# KPI 2: Ciudad con mayor ocupación utilizando un cálculo de promedio por ciudad
# Calcular la ocupación promedio por ciudad
ocupacion_ciudad = df.groupby('city').apply(
    lambda x: ((30 - x['availability_30']).sum() / (30 * len(x))) * 100
)

# Encontrar la ciudad con la mayor ocupación
ciudad_mayor_ocupacion = ocupacion_ciudad.idxmax()
porcentaje_ocupacion_ciudad = ocupacion_ciudad.max()

# KPI 3: Índice de satisfacción general
indice_satisfaccion = df['review_scores_value'].mean()

# KPI 4: Ítem con mayor satisfacción promedio
promedio_items = {
    'accuracy': df['review_scores_accuracy'].mean(),
    'cleanliness': df['review_scores_cleanliness'].mean(),
    'checkin': df['review_scores_checkin'].mean(),
    'communication': df['review_scores_communication'].mean(),
    'location': df['review_scores_location'].mean()
}
item_mayor_satisfaccion = max(promedio_items, key=promedio_items.get)

# Pregunta de Negocio: Precio medio por tipo de alojamiento en cada ciudad
precio_medio = df.groupby(['city', 'room_type'])['price'].mean().unstack().fillna(np.nan)

# Pregunta de Negocio: Disponibilidad media de los alojamientos en 30, 60, 90, 365 días
disponibilidad_media = df.groupby('city')[['availability_30', 'availability_60', 'availability_90', 'availability_365']].mean().apply(np.floor)

# Pregunta de Negocio: Puntuación media y porcentaje con puntuación >80
puntuacion_media = df.groupby('city')['review_scores_rating'].mean().apply(np.floor)
porcentaje_satisfaccion = (df[df['review_scores_rating'] > 80].groupby('city').size() / df.groupby('city').size()) * 100

# Crear el dashboard con Streamlit
st.title('Dashboard de Análisis de Alojamientos')

# KPI 1: Tasa de ocupación
st.header('KPI 1: Tasa de ocupación')
st.markdown(f"<h2 style='font-size: 32px; font-weight: bold;'>Tasa de ocupación general promedio: {df['tasa_ocupacion'].mean():.2f}%</h2>", unsafe_allow_html=True)

# KPI 2: Ciudad con mayor ocupación
st.header('KPI 2: Ciudad con mayor ocupación')
# Mostrar la ciudad con el porcentaje de ocupación
st.markdown(f"<h2 style='font-size: 32px; font-weight: bold; text-transform: uppercase;'>{ciudad_mayor_ocupacion} ({porcentaje_ocupacion_ciudad:.2f}%)</h2>", unsafe_allow_html=True)

# KPI 3: Índice de satisfacción general
st.header('KPI 3: Índice de satisfacción general')
st.markdown(f"<h2 style='font-size: 32px; font-weight: bold;'>{indice_satisfaccion:.2f}</h2>", unsafe_allow_html=True)

# KPI 4: Ítem con mayor satisfacción promedio
st.header('KPI 4: Ítem con mayor satisfacción promedio')
st.markdown(f"<h2 style='font-size: 32px; font-weight: bold;'>{item_mayor_satisfaccion}</h2>", unsafe_allow_html=True)

# Pregunta de Negocio: Precio medio por tipo de alojamiento y ciudad (en formato €)
st.header('Precio medio por tipo de alojamiento y ciudad')
st.dataframe(precio_medio.style.format('${:,.2f}').background_gradient(axis=None).applymap(lambda x: 'background-color: white' if pd.isna(x) else ''))

# Pregunta de Negocio: Disponibilidad media (como números enteros sin color de fondo)
st.header('Disponibilidad media de alojamientos por ciudad')
st.dataframe(disponibilidad_media.astype(int).style.set_table_styles([{
    'selector': 'thead th',
    'props': [('background-color', 'lightgray'), ('font-weight', 'bold')]
}]))

# Pregunta de Negocio: Puntuación media y porcentaje de satisfacción
st.header('Puntuación media y porcentaje de alojamientos con > 80 puntos')
st.write("Puntuación media por ciudad:")
st.dataframe(puntuacion_media)

# Convertir la serie a un DataFrame y aplicar formato
porcentaje_satisfaccion_df = porcentaje_satisfaccion.to_frame(name="Porcentaje de Satisfacción")
st.write("Porcentaje de alojamientos con puntuación mayor a 80:")
st.dataframe(porcentaje_satisfaccion_df.style.format('{:.2f}%'))
