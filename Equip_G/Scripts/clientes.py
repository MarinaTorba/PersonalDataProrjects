import pandas as pd
import numpy as np
import plotly.graph_objects as go
from dash import Dash, dcc, html, Input, Output

# Cargar datos
df = pd.read_csv("2025_04_22_Sprint02.csv")

# Columnas de interés
cols = [
    'review_scores_accuracy',
    'review_scores_cleanliness',
    'review_scores_checkin',
    'review_scores_communication'
]

# Limpiar datos
df_clean = df.dropna(subset=cols + ['review_scores_rating', 'city'])

# Crear app Dash
app = Dash(__name__)

app.layout = html.Div([
    html.H2("Análisis de puntuaciones por ciudad"),

    html.Div([
        html.Label("Ciudad:"),
        dcc.Dropdown(
            id='city-dropdown',
            options=[{'label': city, 'value': city} for city in sorted(df_clean['city'].unique())],
            value=sorted(df_clean['city'].unique())[0]
        )
    ], style={'width': '40%', 'display': 'inline-block', 'verticalAlign': 'top'}),

    dcc.Graph(id='radar-graph'),
    dcc.Graph(id='bar-graph')
])

@app.callback(
    Output('radar-graph', 'figure'),
    Output('bar-graph', 'figure'),
    Input('city-dropdown', 'value')
)
def update_graphs(city):
    filtered = df_clean[df_clean['city'] == city]

    if filtered.empty:
        fig_empty = go.Figure().update_layout(title="No hay datos disponibles para esta selección.")
        return fig_empty, fig_empty

    mejor = filtered.loc[filtered['review_scores_rating'].idxmax()]
    peor = filtered.loc[filtered['review_scores_rating'].idxmin()]
    diferencias = (mejor[cols] - peor[cols])

    labels = diferencias.index.str.replace('review_scores_', '').str.capitalize().tolist()
    values = diferencias.values.tolist()
    labels_radar = labels + [labels[0]]
    values_radar = values + [values[0]]

    # Radar
    radar_fig = go.Figure()
    radar_fig.add_trace(go.Scatterpolar(
        r=values_radar,
        theta=labels_radar,
        fill='toself',
        name='Diferencia',
        line=dict(color='royalblue')
    ))
    radar_fig.update_layout(
        polar=dict(radialaxis=dict(visible=True, range=[0, max(values) + 2])),
        title=f"Radar - {city}",
        showlegend=False
    )

    # Barras
    bar_fig = go.Figure()
    bar_fig.add_trace(go.Bar(
        x=labels,
        y=values,
        marker_color='indianred'
    ))
    bar_fig.update_layout(
        title=f"Diferencias en puntuación - {city}",
        xaxis_title="Categoría",
        yaxis_title="Diferencia (mejor - peor)",
        yaxis=dict(range=[0, max(values) + 2])
    )

    return radar_fig, bar_fig

if __name__ == '__main__':
    app.run_server(debug=True)
