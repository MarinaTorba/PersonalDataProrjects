import streamlit as st
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import os

# Configuración general de la página
st.set_page_config(page_title="Dashboard de Alojamientos", layout="wide")

# Obtener ruta relativa al archivo CSV
base_path = os.path.dirname(os.path.abspath(__file__))
csv_path = os.path.join(base_path, '../Data/2025_04_10_Sprint01.csv')

# Cargar datos
try:
    df = pd.read_csv(csv_path)
except FileNotFoundError:
    st.error("❌ Archivo CSV no encontrado. Verifica la ruta: Data/2025_04_10_Sprint01.csv")
    st.stop()

# Sidebar de filtros
st.sidebar.header("🔎 Filtros")

ciudades = df['city'].unique().tolist()
tipos = df['room_type'].unique().tolist()

ciudades_seleccionadas = st.sidebar.multiselect("Selecciona ciudad(es):", ciudades, default=ciudades)
tipos_seleccionados = st.sidebar.multiselect("Selecciona tipo(s) de alojamiento:", tipos, default=tipos)

# Filtrar DataFrame según selección
df = df[(df['city'].isin(ciudades_seleccionadas)) & (df['room_type'].isin(tipos_seleccionados))]

# Validar si hay datos luego del filtro
if df.empty:
    st.warning("⚠️ No hay datos disponibles para los filtros seleccionados.")
    st.stop()

# Cálculos de KPIs
df['tasa_ocupacion'] = ((30 - df['availability_30']) / 30) * 100

ocupacion_ciudad = df.groupby('city').apply(
    lambda x: ((30 - x['availability_30']).sum() / (30 * len(x))) * 100
)

ciudad_mayor_ocupacion = ocupacion_ciudad.idxmax().upper()
porcentaje_ocupacion_ciudad = ocupacion_ciudad.max()

indice_satisfaccion = df['review_scores_value'].mean()

promedio_items = {
    'accuracy': df['review_scores_accuracy'].mean(),
    'cleanliness': df['review_scores_cleanliness'].mean(),
    'checkin': df['review_scores_checkin'].mean(),
    'communication': df['review_scores_communication'].mean(),
    'location': df['review_scores_location'].mean()
}
item_mayor_satisfaccion = max(promedio_items, key=promedio_items.get)

precio_medio = df.groupby(['city', 'room_type'])['price'].mean().unstack().fillna(np.nan)
disponibilidad_media = df.groupby('city')[['availability_30', 'availability_60', 'availability_90', 'availability_365']].mean().apply(np.floor)
puntuacion_media = df.groupby('city')['review_scores_rating'].mean().apply(np.floor)
porcentaje_satisfaccion = (df[df['review_scores_rating'] > 80].groupby('city').size() / df.groupby('city').size()) * 100

# ---- Estilo visual para tamaño de tablas ----
st.markdown("""
    <style>
    .dataframe th, .dataframe td {
        font-size: 18px !important;
        padding: 10px 16px !important;
    }
    </style>
""", unsafe_allow_html=True)

# Título principal
st.markdown(
    "<h1 style='color:#2E3A59;'>🏨 Dashboard de Alojamientos</h1>", 
    unsafe_allow_html=True
)
st.markdown("<p style='color:#2E3A59;'>Análisis visual de ocupación, satisfacción y precios por ciudad y tipo de alojamiento.</p>", unsafe_allow_html=True)
st.markdown("---")

# KPIs principales
col1, col2, col3, col4 = st.columns(4)

with col1:
    st.metric("📈 Ocupación Promedio", f"{df['tasa_ocupacion'].mean():.2f} %")

with col2:
    st.metric("🏙️ Ciudad Más Ocupada", ciudad_mayor_ocupacion, f"{porcentaje_ocupacion_ciudad:.2f}%")

with col3:
    st.metric("⭐ Índice de Satisfacción", f"{indice_satisfaccion:.2f}")

with col4:
    st.metric("🏅 Mejor Ítem Valorado", item_mayor_satisfaccion.capitalize())

st.markdown("---")

# Precio medio por tipo de alojamiento
st.subheader("💶 Precio Medio por Tipo de Alojamiento y Ciudad")
st.markdown("Valores expresados en euros (€). Se muestra un gradiente de color según el precio.")

st.dataframe(
    precio_medio.style
    .format('€{:,.2f}')
    .background_gradient(axis=1, cmap='Blues', gmap=None)  # Gradiente azul suave
    .applymap(lambda v: 'background-color: white' if pd.isna(v) else ''),  # Celdas vacías en blanco
    use_container_width=True
)

# Disponibilidad media por ciudad
st.subheader("📅 Disponibilidad Media por Ciudad (días disponibles)")

st.dataframe(
    disponibilidad_media.astype(int).style.set_table_styles([{
        'selector': 'thead th',
        'props': [('background-color', '#e1ecf4'), ('color', '#2E3A59'), ('font-weight', 'bold')]
    }]),
    use_container_width=True
)

# Puntuación media por ciudad y porcentaje de satisfacción
st.subheader("🎯 Puntuación Media y % de Alojamientos con +80 Puntos")

col5, col6 = st.columns(2)

with col5:
    st.markdown("**Puntuación Media por Ciudad**")
    st.dataframe(puntuacion_media, use_container_width=True)

with col6:
    st.markdown("**% de Alojamientos con Alta Satisfacción**")
    st.dataframe(
        porcentaje_satisfaccion.to_frame(name="Satisfacción (%)").style.format('{:.2f}%'),
        use_container_width=True
    )

# Gráfico de distribución de puntuaciones
st.markdown("---")
st.subheader("📊 Distribución de Puntuaciones de Clientes")

fig, ax = plt.subplots()
df['review_scores_rating'].hist(bins=20, color='#007B83', edgecolor='white', ax=ax)
ax.set_title("Distribución de Puntuaciones", fontsize=14, color="#2E3A59")
ax.set_xlabel("Puntuación", color="#2E3A59")
ax.set_ylabel("Cantidad de Alojamientos", color="#2E3A59")
fig.patch.set_facecolor('#f8f9fa')
st.pyplot(fig)

# Footer
st.markdown("---")
st.caption("Desarrollado por Equip_G • Powered by Python & Streamlit 🚀")
