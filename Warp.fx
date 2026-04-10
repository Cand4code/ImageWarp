// --- START OF FILE Warp_Pro_Projector_Final.fx ---
#include "ReShade.fxh"

#define RANGE 5.0
#define STEP 0.005

// --- GUI CONTROLS ---

uniform float2 P00 < ui_type = "drag"; ui_label = "NorthWest (X, Y)"; ui_min = -RANGE; ui_max = RANGE; ui_step = STEP; ui_category = "1. Top Row Points"; > = float2(0.0, 0.0);
uniform float2 P01 < ui_type = "drag"; ui_label = "North (X, Y)"; ui_min = -RANGE; ui_max = RANGE; ui_step = STEP; ui_category = "1. Top Row Points"; > = float2(0.0, 0.0);
uniform float2 P02 < ui_type = "drag"; ui_label = "NorthEast (X, Y)"; ui_min = -RANGE; ui_max = RANGE; ui_step = STEP; ui_category = "1. Top Row Points"; > = float2(0.0, 0.0);

uniform float2 P10 < ui_type = "drag"; ui_label = "CenterWest (X, Y)"; ui_min = -RANGE; ui_max = RANGE; ui_step = STEP; ui_category = "2. Center Row Points"; > = float2(0.0, 0.0);
uniform float2 P11 < ui_type = "drag"; ui_label = "Center (X, Y)"; ui_min = -RANGE; ui_max = RANGE; ui_step = STEP; ui_category = "2. Center Row Points"; > = float2(0.0, 0.0);
uniform float2 P12 < ui_type = "drag"; ui_label = "CenterEast (X, Y)"; ui_min = -RANGE; ui_max = RANGE; ui_step = STEP; ui_category = "2. Center Row Points"; > = float2(0.0, 0.0);

uniform float2 P20 < ui_type = "drag"; ui_label = "SouthWest (X, Y)"; ui_min = -RANGE; ui_max = RANGE; ui_step = STEP; ui_category = "3. Bottom Row Points"; > = float2(0.0, 0.0);
uniform float2 P21 < ui_type = "drag"; ui_label = "South (X, Y)"; ui_min = -RANGE; ui_max = RANGE; ui_step = STEP; ui_category = "3. Bottom Row Points"; > = float2(0.0, 0.0);
uniform float2 P22 < ui_type = "drag"; ui_label = "SouthEast (X, Y)"; ui_min = -RANGE; ui_max = RANGE; ui_step = STEP; ui_category = "3. Bottom Row Points"; > = float2(0.0, 0.0);

uniform float GlobalScale < ui_type = "drag"; ui_label = "Global Zoom"; ui_min = 0.1; ui_max = 2.0; ui_step = STEP; ui_category = "4. Global Geometry"; > = 1.0;
uniform float2 GlobalOffset < ui_type = "drag"; ui_label = "Global Offset (X, Y)";	ui_min = -2.0;	ui_max = 2.0;	ui_step = STEP;	ui_category = "4. Global Geometry"; > = float2(0.0, 0.0);
uniform float CurveH < ui_type = "drag";	ui_label = "Horizontal Curvature";	ui_min	= -1.0;	ui_max	= 1.0;	ui_step	= STEP;	ui_category	= "4. Global Geometry"; >	= 0.0;
uniform float CurveV < ui_type	= "drag";	ui_label	= "Vertical Curvature";	ui_min	= -1.0;	ui_max	= 1.0;	ui_step	= STEP;	ui_category	= "4. Global Geometry"; >	= 0.0;
uniform float Linearity < ui_type = "drag"; ui_label = "Center Linearity"; ui_min = 0.5; ui_max = 2.0; ui_step = STEP; ui_category = "4. Global Geometry"; > = 1.0;

uniform bool ShowGrid < ui_label = "Show Calibration Grid"; ui_category = "5. Tools"; > = false;
uniform float GridInfill < ui_type = "slider"; ui_label = "Grid Density"; ui_min = 1.0; ui_max = 5; ui_step = 1.0; ui_category = "5. Tools"; > = 2.0;
uniform bool ShowMarkers < ui_label = "Show Markers"; ui_category = "5. Tools"; > = true;

// --- FUNZIONI ---

float2 QuadraticInterpolate(float2 a, float2 b, float2 c, float t) {
    float invT = 1.0 - t;
    return (invT * invT * a) + (2.0 * invT * t * b) + (t * t * c);
}

// --- PIXEL SHADER ---

float4 ImageWarp(float4 pos : SV_Position, float2 texcoord : TEXCOORD) : SV_Target {
    
    float2 uv = texcoord;

    // 1. TRASLAZIONE GLOBALE (X+ = Destra, Y+ = Alto)
    uv.x -= GlobalOffset.x;
    uv.y += GlobalOffset.y;

    // 2. ZOOM GLOBALE
    uv = (uv - 0.5) / GlobalScale + 0.5;

    // 3. CURVATURA CILINDRICA (Geometria Globale)
    uv.y += (uv.x - 0.5) * (uv.x - 0.5) * CurveH;
    uv.x += (uv.y - 0.5) * (uv.y - 0.5) * CurveV;

    // 4. LINEARITÀ
    float2 lin = uv * 2.0 - 1.0;
    lin = sign(lin) * pow(abs(lin), Linearity);
    uv = lin * 0.5 + 0.5;

    // 5. DEFINIZIONE PUNTI MESH (Correzione Assi: X+ = Destra, Y+ = Alto)
    // Per muovere l'immagine a DESTRA, campioniamo a SINISTRA nelle UV (-X)
    // Per muovere l'immagine in ALTO, campioniamo in BASSO nelle UV (+Y)
    float2 pt00 = float2(0.0 - P00.x, 0.0 + P00.y);
    float2 pt01 = float2(0.5 - P01.x, 0.0 + P01.y);
    float2 pt02 = float2(1.0 - P02.x, 0.0 + P02.y);
    
    float2 pt10 = float2(0.0 - P10.x, 0.5 + P10.y);
    float2 pt11 = float2(0.5 - P11.x, 0.5 + P11.y);
    float2 pt12 = float2(1.0 - P12.x, 0.5 + P12.y);
    
    float2 pt20 = float2(0.0 - P20.x, 1.0 + P20.y);
    float2 pt21 = float2(0.5 - P21.x, 1.0 + P21.y);
    float2 pt22 = float2(1.0 - P22.x, 1.0 + P22.y);

    // 6. CALCOLO WARPING (Spline Quadratica)
    float2 row0 = QuadraticInterpolate(pt00, pt01, pt02, uv.x);
    float2 row1 = QuadraticInterpolate(pt10, pt11, pt12, uv.x);
    float2 row2 = QuadraticInterpolate(pt20, pt21, pt22, uv.x);
    
    float2 finalUV = QuadraticInterpolate(row0, row1, row2, uv.y);

    // 7. CLIPPING (Bordi neri fuori dalla mesh)
    if (finalUV.x < 0.0 || finalUV.x > 1.0 || finalUV.y < 0.0 || finalUV.y > 1.0) {
        return float4(0.0, 0.0, 0.0, 1.0);
    }

    // 8. CAMPIONAMENTO IMMAGINE
    float4 color = tex2D(ReShade::BackBuffer, finalUV);

    // 9. DISEGNO GRIGLIA E MARKER (Basati su finalUV per essere ancorati ai marker)
    if (ShowGrid || ShowMarkers) {
        
        // Calcolo linee griglia (passano esattamente per 0.0, 0.5, 1.0)
        float2 gridCoord = finalUV * GridInfill * 2.0;
        float2 gridFrac = abs(frac(gridCoord + 0.5) - 0.5) / (fwidth(gridCoord));
        float gridLine = 1.0 - smoothstep(0.0, 1.0, min(gridFrac.x, gridFrac.y));

        // Identificazione Bordi (linee esterne 0.0 e 1.0)
        float2 borderDist = min(finalUV, 1.0 - finalUV);
        float edge = 1.0 - smoothstep(0.0, 0.01, min(borderDist.x, borderDist.y));

        // Marker (Cerchi Rossi sui 9 punti di controllo)
        float markerCircles = 0.0;
        if (ShowMarkers) {
            float aspect = BUFFER_WIDTH * BUFFER_RCP_HEIGHT;
            for(float i=0.0; i<=1.0; i+=0.5) {
                for(float j=0.0; j<=1.0; j+=0.5) {
                    float2 d = (finalUV - float2(i, j));
                    d.x *= aspect;
                    markerCircles += smoothstep(0.015, 0.012, length(d));
                }
            }
        }

        // Colori: Rosso per bordi e marker, Ciano per griglia interna
        float3 gridColor = (edge > 0.1) ? float3(1.0, 0.0, 0.0) : float3(0.0, 1.0, 0.8);
        
        if (ShowGrid) {
            color.rgb = lerp(color.rgb, gridColor, gridLine * 0.7);
            color.rgb = lerp(color.rgb, float3(1.0, 0.0, 0.0), edge);
        }
        
        if (ShowMarkers) {
            color.rgb = lerp(color.rgb, float3(1.0, 0.0, 0.0), markerCircles);
        }
    }

    return color;
}

// --- TECHNIQUE ---
technique ImageWarp { 
    pass { 
        VertexShader = PostProcessVS; 
        PixelShader = ImageWarp; 
    } 
}