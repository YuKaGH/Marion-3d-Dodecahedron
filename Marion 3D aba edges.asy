// Параметр t = (a+b)/a. При t=2 получается ромбододекаэдр.
real t = 4;  // можно менять

settings.render = 8;
settings.tex = "none";
import three;
size(500);

// Вершины тетраэдра
triple A = (0,0,0);
triple B = (1,1,0);
triple C = (1,0,1);
triple D = (0,1,1);

// Функция получения бита
int getBit(int num, int pos) {
    int p = 1;
    for (int k = 0; k < pos; ++k) p *= 2;
    return quotient(num, p) % 2;
}

// Генерация вершин (14 штук) – порядок как в вашем исходном коде
triple[] getVertices(real t) {
    triple[] V;
    for (int mask = 1; mask < 15; ++mask) {
        int k = 0;
        for (int i = 0; i < 4; ++i) {
            if (getBit(mask, i) == 1) ++k;
        }
        if (k == 0 || k == 4) continue;
        real alpha = 1.0 / (k + t * (4 - k));
        real[] bary = new real[4];
        for (int i = 0; i < 4; ++i) {
            if (getBit(mask, i) == 1) bary[i] = alpha;
            else bary[i] = t * alpha;
        }
        V.push(bary[0]*A + bary[1]*B + bary[2]*C + bary[3]*D);
    }
    return V;
}

triple[] V = getVertices(t);

// Ваш массив рёбер (индексы 0..13)
int[][] edges = {
    {1,5}, {1,2}, {9,13}, {1,9},
    {2,6}, {5,6}, {2,10},
    {3,5}, {13,11}, {7,11},
    {4,12}, {4,3},
    {5,3}, {5,13},
    {7,9}, {11,12},
    {3,11}, {6,4},
    {8,7}, {8,12},
    {0,4}, {0,2}, {0,8}, {9,10}, {8,10}
};

// --- Автоматическое определение четырёхугольных граней ---
int[][] adj;
for (int i = 0; i < 14; ++i) {
    adj[i] = new int[];
}
for (int[] e : edges) {
    adj[e[0]].push(e[1]);
    adj[e[1]].push(e[0]);
}

int[][] faces;
for (int v = 0; v < 14; ++v) {
    for (int u : adj[v]) {
        for (int w : adj[v]) {
            if (u >= w) continue;
            for (int x : adj[u]) {
                if (x == v) continue;
                bool connected = false;
                for (int y : adj[x]) {
                    if (y == w) { connected = true; break; }
                }
                if (connected) {
                    int[] face = {v, u, x, w};
                    int[] sorted = copy(face);
                    int minpos = 0;
                    for (int i = 1; i < 4; ++i) {
                        if (sorted[i] < sorted[minpos]) minpos = i;
                    }
                    int[] rotated = {sorted[minpos], sorted[(minpos+1)%4], sorted[(minpos+2)%4], sorted[(minpos+3)%4]};
                    int[] reversed = {rotated[0], rotated[3], rotated[2], rotated[1]};
                    if (reversed[1] < rotated[1]) rotated = reversed;
                    faces.push(rotated);
                }
            }
        }
    }
}
int[][] uniqueFaces;
for (int[] f : faces) {
    bool exists = false;
    for (int[] uf : uniqueFaces) {
        if (uf[0] == f[0] && uf[1] == f[1] && uf[2] == f[2] && uf[3] == f[3]) {
            exists = true; break;
        }
    }
    if (!exists) uniqueFaces.push(f);
}

// --- Рисование ---
// Рёбра тетраэдра (серые пунктирные)
draw(A--B, gray+0.6pt+dashed);
draw(A--C, gray+0.6pt+dashed);
draw(A--D, gray+0.6pt+dashed);
draw(B--C, gray+0.6pt+dashed);
draw(B--D, gray+0.6pt+dashed);
draw(C--D, gray+0.6pt+dashed);

// Рёбра многогранника
for (int[] e : edges) {
    draw(V[e[0]] -- V[e[1]], linewidth(0.8pt) + blue);
}

// Заливка граней
for (int[] f : uniqueFaces) {
    path3 poly = V[f[0]] -- V[f[1]] -- V[f[2]] -- V[f[3]] -- cycle;
    draw(surface(poly), green + opacity(0.7));
    draw(poly, blue + linewidth(1pt));
}

// Вершины многогранника
for (int i = 0; i < V.length; ++i) {
    dot(V[i], linewidth(4pt) + red);
}

// Вершины тетраэдра (крупные чёрные)
dot(A, linewidth(4pt) + black);
dot(B, linewidth(4pt) + black);
dot(C, linewidth(4pt) + black);
dot(D, linewidth(4pt) + black);
//label("A", A, SW);
//label("B", B, SE);
//label("C", C, NE);
//label("D", D, NW);

// Точки деления на рёбрах (маленькие красные, без подписи)
real u1 = 1/(1+t);
real u2 = t/(1+t);
triple[][] tetEdges = {{A,B}, {A,C}, {A,D}, {B,C}, {B,D}, {C,D}};
for (int i = 0; i < tetEdges.length; ++i) {
    triple P = tetEdges[i][0];
    triple Q = tetEdges[i][1];
    dot(P + u1*(Q-P), red+linewidth(4pt));
    dot(P + u2*(Q-P), red+linewidth(4pt));
}

// Подписи вершин многогранника (можно закомментировать)
//string[] labels = {"V0","V1","V2","V3","V4","V5","V6","V7","V8","V9","V10","V11","V12","V13"};
//for (int i = 0; i < V.length; ++i) {
    //label(labels[i], V[i], align=unit(V[i] - (0.5,0.2,0.1)), fontsize(7pt));
//}

currentprojection = orthographic(2, 1.5, 1);
currentlight = White;
