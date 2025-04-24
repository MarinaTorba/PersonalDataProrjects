import dash
from dash import dcc, html, dash_table
import plotly.graph_objects as go
import pandas as pd
import numpy as np

# Inicializar la app Dash
app = dash.Dash(__name__)

# Ruta al archivo CSV
csv_path = r'../Data/2025_04_22_Sprint02.csv'
df = pd.read_csv(csv_path)

# ==============================
# KPIs
# ==============================
df['tasa_ocupacion'] = ((30 - df['availability_30']) / 30) * 100

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
# 🎨 Estilos CSS
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
    }
}

# ==============================
# Correlación características-precio
# ==============================
variables_correlacion = ['accommodates', 'bedrooms', 'beds', 'review_scores_location', 'price']
df_corr = df[['city'] + variables_correlacion].dropna()
resultados_correlacion = {}

for ciudad, subdf in df_corr.groupby('city'):
    subdf_numerico = subdf[variables_correlacion]
    correlaciones = subdf_numerico.corr().loc['price'].drop('price')
    resultados_correlacion[ciudad] = correlaciones

correlaciones_precio = pd.DataFrame(resultados_correlacion).T.round(2)

fig_correlacion = go.Figure(data=go.Heatmap(
    z=correlaciones_precio.values,
    x=[col.replace('_', ' ').capitalize() for col in correlaciones_precio.columns],
    y=correlaciones_precio.index.str.capitalize(),
    colorscale='RdBu',
    zmin=-1,
    zmax=1,
    text=correlaciones_precio.values.round(2),
    hoverinfo='text',
    texttemplate="%{text}",
    colorbar=dict(title="Correlación")
))

fig_correlacion.update_layout(
    title='Mapa de calor de correlación entre características y precios por ciudad',
    xaxis_title='Características',
    yaxis_title='Ciudad',
    title_font=dict(size=22),
    margin=dict(t=80, l=100, r=50, b=100)
)

# Texto explicativo
top_vars = correlaciones_precio.abs().mean().sort_values(ascending=False).head(3).index
top_vars_nombres = [v.replace('_', ' ').capitalize() for v in top_vars]
ciudades_destacadas = correlaciones_precio.loc[:, top_vars].abs().mean(axis=1).sort_values(ascending=False).head(3).index
ciudades_nombres = [c.capitalize() for c in ciudades_destacadas]

texto_correlacion = f"""
El análisis muestra que las características con más correlación con el precio son: {', '.join(top_vars_nombres)}.
Esto indica que estos factores tienen un gran impacto sobre el valor de los alojamientos.
Las ciudades donde esta relación es más destacada son: {', '.join(ciudades_nombres)}.
"""

# ==============================
# 🛠 OPERACIONES
# ==============================
# Impacto reserva automática
df_Book = df.groupby(['city', 'is_instant_bookable'])[
    ['availability_30', 'availability_60', 'availability_90', 'availability_365']
].mean().reset_index()

pivot_df_Book = df_Book.pivot(index='city', columns='is_instant_bookable')

# ✅ Aplanar columnas MultiIndex para evitar errores
pivot_df_Book.columns = [f"{col[0]}_{col[1]}" if isinstance(col, tuple) else col for col in pivot_df_Book.columns]

# Calcular coeficientes de disponibilidad
for dias in ['30', '60', '90', '365']:
    col_true = f'availability_{dias}_VERDADERO'
    col_false = f'availability_{dias}_FALSO'
    pivot_df_Book[f'Coeficiente ({dias} días)'] = (
        pivot_df_Book[col_true] - pivot_df_Book[col_false]
    ) / (
        pivot_df_Book[col_true] + pivot_df_Book[col_false]
    )

# Crear gráfica
ciudades = pivot_df_Book.index.tolist()
fig_reserva_auto = go.Figure()
fig_reserva_auto.add_trace(go.Bar(x=ciudades, y=pivot_df_Book['Coeficiente (30 días)'], name='30 días', marker_color='#ADD8E6'))
fig_reserva_auto.add_trace(go.Bar(x=ciudades, y=pivot_df_Book['Coeficiente (60 días)'], name='60 días', marker_color='#87CEEB'))
fig_reserva_auto.add_trace(go.Bar(x=ciudades, y=pivot_df_Book['Coeficiente (90 días)'], name='90 días', marker_color='#4682B4'))
fig_reserva_auto.add_trace(go.Bar(x=ciudades, y=pivot_df_Book['Coeficiente (365 días)'], name='365 días', marker_color='#00008B'))

fig_reserva_auto.update_layout(
    barmode='group',
    title='Impacto de la reserva automática en la disponibilidad media',
    xaxis_title='Ciudad',
    yaxis_title='Coeficiente de disponibilidad',
    yaxis=dict(range=[-0.25, 0.25]),
    title_font=dict(size=22)
)

# Taula de resum: nombre d’allotjaments amb/sense reserva automàtica
tabla_resumen_Book = df.groupby(['city', 'is_instant_bookable']).size().unstack(fill_value=0)
tabla_resumen_Book.columns = ['Sin reserva automática', 'Con reserva automática']
tabla_resumen_Book = tabla_resumen_Book.reset_index()

# Taula de coeficients de disponibilitat
tabla_coeficientes_disponibilidad = pivot_df_Book[[
    "Coeficiente (30 días)",
    "Coeficiente (60 días)",
    "Coeficiente (90 días)",
    "Coeficiente (365 días)"
]].reset_index().round(2)

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
        html.H2("¿Qué características de los alojamientos estan más relacionadas con los precios?", style=styles['titulo']),
        html.P(texto_correlacion, style={
            'text-align': 'justify',
            'font-size': '18px',
            'margin': '20px 80px'
        }),
        dcc.Graph(id='correlation-by-city', figure=fig_correlacion)
    ], style=styles['seccion']),

    html.Div([
        html.H2("Operaciones", style=styles['titulo']),
        html.H3("¿Qué impacto tiene la opción de reservar automáticamente (sin revisión del propietario) en la disponibilidad media en cada ciudad?", style={
            'text-align': 'center',
            'font-size': '24px',
            'color': '#1E2A38',
            'margin': '30px 0'
        }),
        dcc.Graph(figure=fig_reserva_auto),

        html.H3("Distribución de alojamientos con/sin reserva automática", style={
            'text-align': 'center',
            'font-size': '22px',
            'color': '#1E2A38',
            'margin': '40px 0 20px 0'
        }),
        dash_table.DataTable(
            columns=[{"name": col, "id": col} for col in tabla_resumen_Book.columns],
            data=tabla_resumen_Book.to_dict('records'),
            style_cell={'textAlign': 'center', 'fontSize': 16, 'padding': '10px'},
            style_header={
                'backgroundColor': '#1E2A38',
                'color': 'white',
                'fontWeight': 'bold',
                'fontSize': 18
            },
            style_table={'width': '80%', 'margin': '0 auto'}
        ),

        html.H3("Coeficientes de disponibilidad para reserva automática", style={
            'text-align': 'center',
            'font-size': '22px',
            'color': '#1E2A38',
            'margin': '40px 0 20px 0'
        }),
        dash_table.DataTable(
            columns=[{"name": col, "id": col} for col in tabla_coeficientes_disponibilidad.columns],
            data=tabla_coeficientes_disponibilidad.to_dict('records'),
            style_cell={'textAlign': 'center', 'fontSize': 16, 'padding': '10px'},
            style_header={
                'backgroundColor': '#1E2A38',
                'color': 'white',
                'fontWeight': 'bold',
                'fontSize': 18
            },
            style_table={'width': '80%', 'margin': '0 auto'}
        )
    ], style={'width': '90%', 'margin': '0 auto'})
], style=styles['seccion'])


# Ejecutar la aplicación
if __name__ == '__main__':
    app.run(debug=True)
