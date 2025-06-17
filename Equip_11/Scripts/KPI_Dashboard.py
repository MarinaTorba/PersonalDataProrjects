import streamlit as st
import pandas as pd
import os
print(os.getcwd())

# Ruta base: carpeta actual donde se ejecuta el notebook
BASE_DIR = os.getcwd()
# Ruta al archivo CSV
csv_path = os.path.join(BASE_DIR, '..', 'Data', 'RRHH - semana1.csv')
# Cargar CSV
df_RRHH = pd.read_csv(csv_path)

# Convertir columnas si es necesario
df_RRHH['Work_load_Average_day'] = (
    df_RRHH['Work_load_Average_day']
    .astype(str)
    .str.replace(',', '.', regex=False)
    .astype(float)
)

# Diccionario de nombres de meses
nombres_meses = ['Enero','Febrero','Marzo','Abril','Mayo','Junio','Julio','Agosto','Septiembre','Octubre','Noviembre','Diciembre']

# 1. KPI: Tasa mensual de absentismo per cápita por mes
monthly_data = df_RRHH.groupby('Month_absence').agg({
    'Absenteeism_hours': 'sum',
    'ID': pd.Series.nunique
}).rename(columns={'ID': 'Num_empleados'})
monthly_data['Tasa_per_capita'] = monthly_data['Absenteeism_hours'] / monthly_data['Num_empleados']

# Último mes con datos
ultimo_mes = monthly_data.index.max()
tasa_per_capita = monthly_data.loc[ultimo_mes, 'Tasa_per_capita']

# 2. KPI: Mes pico de carga por ausencias
mes_pico = monthly_data['Absenteeism_hours'].idxmax()
mes_pico_nombre = nombres_meses[int(mes_pico)-1] if 1 <= int(mes_pico) <= 12 else str(mes_pico)

# 3. KPI: Motivo modal de absentismo
motivo_ausencia = {
    0: 'Sin ausencia',
    1: 'I Enfermedades infecciosas y parasitarias',
    2: 'II Neoplasias',
    3: 'III Enfermedades de la sangre y sistema inmunológico',
    4: 'IV Endocrinas, nutricionales y metabólicas',
    5: 'V Trastornos mentales',
    6: 'VI Sistema nervioso',
    7: 'VII Ojo y anexos',
    8: 'VIII Oído y apófisis mastoides',
    9: 'IX Sistema circulatorio',
    10: 'X Sistema respiratorio',
    11: 'XI Sistema digestivo',
    12: 'XII Piel y tejido subcutáneo',
    13: 'XIII Sistema osteomuscular',
    14: 'XIV Sistema genitourinario',
    15: 'XV Embarazo y parto',
    16: 'XVI Condiciones perinatales',
    17: 'XVII Malformaciones congénitas',
    18: 'XVIII Síntomas y signos no clasificados',
    19: 'XIX Lesiones y envenenamientos',
    20: 'XX Causas externas',
    21: 'XXI Factores sociales/salud',
    22: 'Seguimiento (sin CID)',
    23: 'Consulta médica (sin CID)',
    24: 'Donación de sangre (sin CID)',
    25: 'Examen de laboratorio (sin CID)',
    26: 'Ausencia injustificada (sin CID)',
    27: 'Fisioterapia (sin CID)',
    28: 'Consulta odontológica (sin CID)'
}
modal_code = df_RRHH[df_RRHH['Reason_absence'] != 0]['Reason_absence'].mode().values[0]
motivo_modal = motivo_ausencia.get(modal_code, str(modal_code))

# 4. KPI: Índice de eficiencia
hit_sum = df_RRHH['Hit_target'].sum()
carga_sum = df_RRHH['Work_load_Average_day'].sum()
indice_eficiencia = hit_sum / carga_sum if carga_sum != 0 else 0

# STREAMLIT DASHBOARD
st.set_page_config(page_title="KPIs Absentismo", layout="centered")
st.title("📊 Dashboard de KPIs de Absentismo Laboral")

col1, col2 = st.columns(2)
col1.metric("🕒 Tasa per cápita (mes {0})".format(nombres_meses[int(ultimo_mes)-1]), f"{tasa_per_capita:.1f} h")
col2.metric("📈 Mes pico de ausencias", mes_pico_nombre)

col3, col4 = st.columns(2)
col3.metric("🧾 Motivo modal de absentismo", motivo_modal)
col4.metric("⚙️ Índice eficiencia laboral", f"{indice_eficiencia:.2%}")

# Gráfico: Evolución mensual de la tasa per cápita
st.markdown("### 📊 Evolución mensual de la tasa per cápita")
monthly_data_viz = monthly_data.copy()
monthly_data_viz.index = monthly_data_viz.index.map(lambda m: nombres_meses[int(m)-1] if 1 <= int(m) <= 12 else str(m))
st.bar_chart(monthly_data_viz['Tasa_per_capita'])
