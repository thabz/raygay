
#include "filters/gaussianblur.h"
#include "image/image.h"
#include <cassert>

using namespace std;

GaussianBlur::GaussianBlur(double radius) {
    assert(radius > 0);
    this->radius = radius;
}

void GaussianBlur::apply(Image* image) {

    int h = (int)radius;
    double* mask = (double*) alloca( sizeof(double) * h * h);

    for(int x = 0; x < radius; x++) {
	for(int y = 0; y < radius; y++) {
	    double u = (x - radius / 2) / radius;
	    double v = (y - radius / 2) / radius;
            double w = u * u + v * v;
	    double val = exp( -0.5 * w * w);
	    mask[x + h * y] = val;
	}
    }
    normalizeMask(mask,h,h);

    applyMask(image, mask, h, h);
}