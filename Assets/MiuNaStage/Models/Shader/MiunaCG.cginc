#ifndef MIUNA_CG_INCLUDED
#define MIUNA_CG_INCLUDED

// Reference: Valve
// from [-1, 1] to [0, 1]
inline fixed halfLambert(fixed value) {
	return 0.5*value + 0.5;
}

#endif // MIUNA_CG_INCLUDED