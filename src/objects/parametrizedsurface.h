
#ifndef PARAMETRIZED_SURFACE_H
#define PARAMETRIZED_SURFACE_H

#include "mesh.h"
#include <vector>

/**
 * A parametrized surface is a mesh constructed from a function
 * \$[ F: [0,1][0,1] \rarr R^3 \$].
 */
class ParametrizedSurface : public Mesh 
{
    public:
	ParametrizedSurface(uint uRes, uint vRes, bool uClose, bool vClose, const Material* m);
	void prepare();

    protected:
	virtual Vector eval(double u, double v) const = 0;

    private:
	uint uRes, vRes;
	bool uClose, vClose;
};

#endif
