import dash
from dash import dcc, html
import plotly.graph_objects as go
import pandas as pd
import numpy as np

# Inicializar la app Dash
app = dash.Dash(__name__)

# Ruta al archivo CSV
csv_path = r'../Data/2025_04_22_Sprint02.csv'
df = pd.read_csv(csv_path)

# ==============================
# PREPROCESAMIENTO Y KPIs
# ==============================
df['tasa_ocupacion'] = ((30 - df['availability_30']) / 30) * 100
df['num_amenities'] = df['normalized_amenities'].apply(lambda x: len(str(x).split(',')) if pd.notnull(x) else 0)

ocupacion_ciudad = df.groupby('city').apply(
    lambda x: ((30 - x['availability_30']).sum() / (30 * len(x))) * 100
)

ciudad_mayor_ocupacion = ocupacion_ciudad.idxmax()
porcentaje_ocupacion_ciudad = ocupacion_ciudad.max()

indice_satisfaccion = df[['review_scores_value', 'room_type']].groupby('room_type').mean().mean()['review_scores_value']

mejor_item_valorado = df[[ 
    'review_scores_accuracy', 
    'review_scores_cleanliness', 
    'review_scores_checkin', 
    'review_scores_communication', 
    'review_scores_location' 
]].mean().idxmax()

valor_mejor_item = df[mejor_item_valorado].mean()

# ==============================
# 🎨 Estilos CSS centralizados
# ==============================
styles = {
    'titulo': {
        'text-align': 'center',
        'color': '#1E2A38',
        'font-size': '40px'
    },
    'kpi_box': {
        'width': '22%',
        'display': 'inline-block',
        'margin': '20px 0',
        'text-align': 'center',
        'border': '2px solid #17a2b8',
        'border-radius': '8px',
        'padding': '20px',
        'box-sizing': 'border-box',
        'background-color': '#f9f9f9'
    },
    'kpi_container': {
        'display': 'flex',
        'justify-content': 'space-between',
        'flex-wrap': 'nowrap',
        'gap': '10px'
    },
    'kpi_text': {
        'font-size': '36px',
        'color': '#17a2b8',
        'text-align': 'center'
    },
    'seccion': {
        'margin-top': '50px'
    },
    'graph': {
        'title_size': 40,
        'axis_title': 28,
        'ticks': 24,
        'text_cell': 22
    }
}

# ==============================
# Correlación entre características y precio por ciudad
# ==============================
variables_correlacion = [
    'accommodates', 'bedrooms', 'beds', 'review_scores_location', 'num_amenities', 'price'
]
df_corr = df[['city'] + variables_correlacion].dropna()
resultados_correlacion = {}

for ciudad, subdf in df_corr.groupby('city'):
    correlaciones = subdf[variables_correlacion].corr().loc['price'].drop('price')
    resultados_correlacion[ciudad] = correlaciones

correlaciones_precio = pd.DataFrame(resultados_correlacion).T.round(2)

# Etiquetas con valor de correlación promedio
column_labels = [
    f"{var.replace('_', ' ').capitalize()} ({correlaciones_precio[var].abs().mean():.2f})"
    for var in correlaciones_precio.columns
]

fig_correlacion = go.Figure(data=go.Heatmap(
    z=correlaciones_precio.values,
    x=column_labels,
    y=correlaciones_precio.index.str.capitalize(),
    colorscale='RdBu',
    zmin=-1,
    zmax=1,
    text=correlaciones_precio.values.round(2),
    hoverinfo='text',
    texttemplate="%{text}",
    colorbar=dict(title="Correlació")
))

fig_correlacion.update_traces(
    textfont={"size": 20}  # Tamaño del texto dentro de las celdas
)

fig_correlacion.update_layout(
    title='Mapa de calor de correlación entre características y precios por ciudad',
    xaxis_title='Características (media de correlación con precio)',
    yaxis_title='Ciudad',
    title_font=dict(size=22),
    margin=dict(t=80, l=100, r=50, b=100),
    xaxis=dict(tickfont=dict(size=20)),
    yaxis=dict(tickfont=dict(size=20))
)


# ==============================
# Texto dinámico para correlación
# ==============================
top_vars = correlaciones_precio.abs().mean().sort_values(ascending=False).head(3).index

top_vars_texto = [
    f"{var.replace('_', ' ').capitalize()} ({correlaciones_precio[var].abs().mean():.2f})"
    for var in top_vars
]

ciudades_destacadas = correlaciones_precio[top_vars].abs().mean(axis=1).sort_values(ascending=False).head(3).index
ciudades_nombres = [c.capitalize() for c in ciudades_destacadas]

texto_correlacion = f"""
El análisis muestra que las características con mayor correlación con el precio son: {', '.join(top_vars_texto)}.
Esto indica que estos factores tienen un gran impacto sobre el valor de los alojamientos.
Las ciudades en las que esta relación es más destacada son: {', '.join(ciudades_nombres)}.
"""

# ==============================
# Layout de la aplicación
# ==============================
app.layout = html.Div([
    html.H1("🏨 Dashboard de Alojamientos", style=styles['titulo']),
    html.H1("Equipo_G", style=styles['titulo']),

    html.Div([
        html.Div([
            html.Div([
                html.H4(f"📊 Total de registros analizados: {len(df):,} registros", style=styles['kpi_text']),
            ], style={**styles['kpi_box'], 'width': '100%', 'margin': '0 0 20px 0'}),

            html.Div([
                html.Div([
                    html.H4(f"📈 Ocupación Promedio (mensual): {df['tasa_ocupacion'].mean():.2f}%", style=styles['kpi_text']),
                ], style=styles['kpi_box']),

                html.Div([
                    html.H4(f"🏙️ Ciudad Más Ocupada (mensual): {ciudad_mayor_ocupacion.capitalize()} - {porcentaje_ocupacion_ciudad:.2f}%", style=styles['kpi_text']),
                ], style=styles['kpi_box']),

                html.Div([
                    html.H4(f"⭐ Índice de Satisfacción General: {indice_satisfaccion:.2f}", style=styles['kpi_text']),
                ], style=styles['kpi_box']),

                html.Div([
                    html.H4(f"🏅 Mejor Ítem Valorado: {mejor_item_valorado.split('_')[-1].capitalize()} - {valor_mejor_item:.0f}", style=styles['kpi_text']),
                ], style=styles['kpi_box']),
            ], style=styles['kpi_container']),
        ], style={'width': '90%', 'margin': '0 auto'}),
    ]),

    html.Div([
        html.H2("¿Qué características de los alojamientos (comodidades, capacidad y puntuación de la zona) están más relacionadas con los precios en cada ciudad?", style=styles['titulo']),
        html.P(texto_correlacion, style={
            'text-align': 'justify',
            'font-size': '22px',
            'line-height': '1.6',
            'margin': '30px 0',
            'color': '#1E2A38',
            'font-weight': '500'
        }),
        dcc.Graph(id='correlation-by-city', figure=fig_correlacion)
    ], style={'width': '90%', 'margin': '0 auto'})
], style=styles['seccion'])

# ==============================
# Ejecutar la app
# ==============================
if __name__ == '__main__':
    app.run(debug=True)

