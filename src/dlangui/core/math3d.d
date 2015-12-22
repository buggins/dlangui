module dlangui.core.math3d;

import std.math;

/// 3 dimensional vector
struct vec3 {
	union {
		float[3] vec;
		struct {
			float x;
			float y;
			float z;
		}
	}
	alias vec this;
	//@property ref float x() { return vec[0]; }
	//@property ref float y() { return vec[1]; }
	//@property ref float z() { return vec[2]; }
	alias r = x;
	alias g = y;
	alias b = z;
	this(float[3] v) {
		vec = v;
	}
	this(vec3 v) {
		vec = v.vec;
	}
	this(float x, float y, float z) {
		vec[0] = x;
		vec[1] = y;
		vec[2] = z;
	}
	ref vec3 opAssign(float[3] v) {
		vec = v;
		return this;
	}
	ref vec3 opAssign(vec3 v) {
		vec = v.vec;
		return this;
	}
	ref vec3 opAssign(float x, float y, float z) {
		vec[0] = x;
		vec[1] = y;
		vec[2] = z;
		return this;
	}
	/// fill all components of vector with specified value
	ref vec3 clear(float v) {
		vec[0] = vec[1] = vec[2] = v;
		return this;
	}
	/// add value to all components of vector
	ref vec3 add(float v) {
		vec[0] += v;
		vec[1] += v;
		vec[2] += v;
		return this;
	}
	/// multiply all components of vector by value
	ref vec3 mul(float v) {
		vec[0] *= v;
		vec[1] *= v;
		vec[2] *= v;
		return this;
	}
	/// subtract value from all components of vector
	ref vec3 sub(float v) {
		vec[0] -= v;
		vec[1] -= v;
		vec[2] -= v;
		return this;
	}
	/// divide all components of vector by value
	ref vec3 div(float v) {
		vec[0] /= v;
		vec[1] /= v;
		vec[2] /= v;
		return this;
	}
	/// add components of another vector to corresponding components of this vector
	ref vec3 add(vec3 v) {
		vec[0] += v[0];
		vec[1] += v[1];
		vec[2] += v[2];
		return this;
	}
	/// multiply components of this vector  by corresponding components of another vector
	ref vec3 mul(vec3 v) {
		vec[0] *= v[0];
		vec[1] *= v[1];
		vec[2] *= v[2];
		return this;
	}
	/// subtract components of another vector from corresponding components of this vector
	ref vec3 sub(vec3 v) {
		vec[0] -= v[0];
		vec[1] -= v[1];
		vec[2] -= v[2];
		return this;
	}
	/// divide components of this vector  by corresponding components of another vector
	ref vec3 div(vec3 v) {
		vec[0] /= v[0];
		vec[1] /= v[1];
		vec[2] /= v[2];
		return this;
	}

	/// add value to all components of vector
	vec3 opBinary(string op : "+")(float v) const {
		vec3 res;
		res.vec[0] += v;
		res.vec[1] += v;
		res.vec[2] += v;
		return res;
	}
	/// multiply all components of vector by value
	vec3 opBinary(string op : "*")(float v) const {
		vec3 res;
		res.vec[0] *= v;
		res.vec[1] *= v;
		res.vec[2] *= v;
		return res;
	}
	/// subtract value from all components of vector
	vec3 opBinary(string op : "-")(float v) const {
		vec3 res;
		res.vec[0] -= v;
		res.vec[1] -= v;
		res.vec[2] -= v;
		return res;
	}
	/// divide all components of vector by value
	vec3 opBinary(string op : "/")(float v) const {
		vec3 res;
		res.vec[0] /= v;
		res.vec[1] /= v;
		res.vec[2] /= v;
		return res;
	}


	/// add value to all components of vector
	ref vec3 opOpAssign(string op : "+")(float v) {
		vec[0] += v;
		vec[1] += v;
		vec[2] += v;
		return this;
	}
	/// multiply all components of vector by value
	ref vec3 opOpAssign(string op : "*")(float v) {
		vec[0] *= v;
		vec[1] *= v;
		vec[2] *= v;
		return this;
	}
	/// subtract value from all components of vector
	ref vec3 opOpAssign(string op : "-")(float v) {
		vec[0] -= v;
		vec[1] -= v;
		vec[2] -= v;
		return this;
	}
	/// divide all components of vector by value
	ref vec3 opOpAssign(string op : "/")(float v) {
		vec[0] /= v;
		vec[1] /= v;
		vec[2] /= v;
		return this;
	}

	/// by component add values of corresponding components of other vector
	ref vec3 opOpAssign(string op : "+")(const vec3 v) {
		vec[0] += v.vec[0];
		vec[1] += v.vec[1];
		vec[2] += v.vec[2];
		return this;
	}
	/// by component multiply values of corresponding components of other vector
	ref vec3 opOpAssign(string op : "*")(const vec3 v) {
		vec[0] *= v.vec[0];
		vec[1] *= v.vec[1];
		vec[2] *= v.vec[2];
		return this;
	}
	/// by component subtract values of corresponding components of other vector
	ref vec3 opOpAssign(string op : "-")(const vec3 v) {
		vec[0] -= v.vec[0];
		vec[1] -= v.vec[1];
		vec[2] -= v.vec[2];
		return this;
	}
	/// by component divide values of corresponding components of other vector
	ref vec3 opOpAssign(string op : "/")(const vec3 v) {
		vec[0] /= v.vec[0];
		vec[1] /= v.vec[1];
		vec[2] /= v.vec[2];
		return this;
	}


	/// add value to all components of vector
	vec3 opBinary(string op : "+")(const vec3 v) const {
		vec3 res;
		res.vec[0] += v.vec[0];
		res.vec[1] += v.vec[1];
		res.vec[2] += v.vec[2];
		return res;
	}
	/// subtract value from all components of vector
	vec3 opBinary(string op : "-")(const vec3 v) const {
		vec3 res;
		res.vec[0] -= v.vec[0];
		res.vec[1] -= v.vec[1];
		res.vec[2] -= v.vec[2];
		return res;
	}
	/// subtract value from all components of vector
	float opBinary(string op : "*")(const vec3 v) const {
		return dot(v);
	}
	/// dot product (sum of by-component products of vector components)
	float dot(const vec3 v) const {
		float res = 0.0f;
		res += vec[0] * v.vec[0];
		res += vec[1] * v.vec[1];
		res += vec[2] * v.vec[2];
		return res;
	}

	/// sum of squares of all vector components
	@property float magnitudeSquared() {
		return vec[0]*vec[0] + vec[1]*vec[1] + vec[2]*vec[2];
	}

	/// length of vector
	@property float magnitude() {
		return sqrt(magnitudeSquared);
	}

	alias length = magnitude;

	/// normalize vector: make its length == 1
	void normalize() {
		div(length);
	}

	/// returns normalized copy of this vector
	@property vec3 normalized() {
		vec3 res = this;
		res.normalize();
		return res;
	}

}

/// 4 component vector
struct vec4 {
	float[4] vec;
	alias vec this;
	@property ref float x() { return vec[0]; }
	@property ref float y() { return vec[1]; }
	@property ref float z() { return vec[2]; }
	@property ref float w() { return vec[3]; }
	alias r = x;
	alias g = y;
	alias b = z;
	alias a = w;
	this(float[4] v) {
		vec = v;
	}
	this(vec4 v) {
		vec = v.vec;
	}
	this(float x, float y, float z, float w) {
		vec[0] = x;
		vec[1] = y;
		vec[2] = z;
		vec[3] = w;
	}
	this(vec3 v) {
		vec[0] = v[0];
		vec[1] = v[1];
		vec[2] = v[2];
		vec[3] = 1.0f;
	}
	ref vec4 opAssign(const float[4] v) {
		vec = v;
		return this;
	}
	ref vec4 opAssign(const vec4 v) {
		vec = v.vec;
		return this;
	}
	ref vec4 opAssign(float x, float y, float z, float w) {
		vec[0] = x;
		vec[1] = y;
		vec[2] = z;
		vec[3] = w;
		return this;
	}
	ref vec4 opAssign(const vec3 v) {
		vec[0] = v[0];
		vec[1] = v[1];
		vec[2] = v[2];
		vec[3] = 1.0f;
		return this;
	}


	/// fill all components of vector with specified value
	ref vec4 clear(float v) {
		vec[0] = vec[1] = vec[2] = vec[3] = v;
		return this;
	}
	/// add value to all components of vector
	ref vec4 add(float v) {
		vec[0] += v;
		vec[1] += v;
		vec[2] += v;
		vec[3] += v;
		return this;
	}
	/// multiply all components of vector by value
	ref vec4 mul(float v) {
		vec[0] *= v;
		vec[1] *= v;
		vec[2] *= v;
		vec[3] *= v;
		return this;
	}
	/// subtract value from all components of vector
	ref vec4 sub(float v) {
		vec[0] -= v;
		vec[1] -= v;
		vec[2] -= v;
		vec[3] -= v;
		return this;
	}
	/// divide all components of vector by value
	ref vec4 div(float v) {
		vec[0] /= v;
		vec[1] /= v;
		vec[2] /= v;
		vec[3] /= v;
		return this;
	}
	/// add components of another vector to corresponding components of this vector
	ref vec4 add(const vec4 v) {
		vec[0] += v[0];
		vec[1] += v[1];
		vec[2] += v[2];
		vec[3] += v[3];
		return this;
	}
	/// multiply components of this vector  by corresponding components of another vector
	ref vec4 mul(vec4 v) {
		vec[0] *= v[0];
		vec[1] *= v[1];
		vec[2] *= v[2];
		vec[3] *= v[3];
		return this;
	}
	/// subtract components of another vector from corresponding components of this vector
	ref vec4 sub(vec4 v) {
		vec[0] -= v[0];
		vec[1] -= v[1];
		vec[2] -= v[2];
		vec[3] -= v[3];
		return this;
	}
	/// divide components of this vector  by corresponding components of another vector
	ref vec4 div(vec4 v) {
		vec[0] /= v[0];
		vec[1] /= v[1];
		vec[2] /= v[2];
		vec[3] /= v[3];
		return this;
	}

	/// add value to all components of vector
	vec4 opBinary(string op : "+")(float v) const {
		vec4 res;
		res.vec[0] += v;
		res.vec[1] += v;
		res.vec[2] += v;
		res.vec[3] += v;
		return res;
	}
	/// multiply all components of vector by value
	vec4 opBinary(string op : "*")(float v) const {
		vec4 res;
		res.vec[0] *= v;
		res.vec[1] *= v;
		res.vec[2] *= v;
		res.vec[3] *= v;
		return res;
	}
	/// subtract value from all components of vector
	vec4 opBinary(string op : "-")(float v) const {
		vec4 res;
		res.vec[0] -= v;
		res.vec[1] -= v;
		res.vec[2] -= v;
		res.vec[3] -= v;
		return res;
	}
	/// divide all components of vector by value
	vec4 opBinary(string op : "/")(float v) const {
		vec4 res;
		res.vec[0] /= v;
		res.vec[1] /= v;
		res.vec[2] /= v;
		res.vec[3] /= v;
		return res;
	}

	/// add value to all components of vector
	ref vec4 opOpAssign(string op : "+")(float v) {
		vec[0] += v;
		vec[1] += v;
		vec[2] += v;
		vec[3] += v;
		return this;
	}
	/// multiply all components of vector by value
	ref vec4 opOpAssign(string op : "*")(float v) {
		vec[0] *= v;
		vec[1] *= v;
		vec[2] *= v;
		vec[3] *= v;
		return this;
	}
	/// subtract value from all components of vector
	ref vec4 opOpAssign(string op : "-")(float v) {
		vec[0] -= v;
		vec[1] -= v;
		vec[2] -= v;
		vec[3] -= v;
		return this;
	}
	/// divide all components of vector by value
	ref vec4 opOpAssign(string op : "/")(float v) {
		vec[0] /= v;
		vec[1] /= v;
		vec[2] /= v;
		vec[3] /= v;
		return this;
	}

	/// by component add values of corresponding components of other vector
	ref vec4 opOpAssign(string op : "+")(const vec4 v) {
		vec[0] += v.vec[0];
		vec[1] += v.vec[1];
		vec[2] += v.vec[2];
		vec[3] += v.vec[3];
		return this;
	}
	/// by component multiply values of corresponding components of other vector
	ref vec4 opOpAssign(string op : "*")(const vec4 v) {
		vec[0] *= v.vec[0];
		vec[1] *= v.vec[1];
		vec[2] *= v.vec[2];
		vec[3] *= v.vec[3];
		return this;
	}
	/// by component subtract values of corresponding components of other vector
	ref vec4 opOpAssign(string op : "-")(const vec4 v) {
		vec[0] -= v.vec[0];
		vec[1] -= v.vec[1];
		vec[2] -= v.vec[2];
		vec[3] -= v.vec[3];
		return this;
	}
	/// by component divide values of corresponding components of other vector
	ref vec4 opOpAssign(string op : "/")(const vec4 v) {
		vec[0] /= v.vec[0];
		vec[1] /= v.vec[1];
		vec[2] /= v.vec[2];
		vec[3] /= v.vec[3];
		return this;
	}



	/// add value to all components of vector
	vec4 opBinary(string op : "+")(const vec4 v) const {
		vec4 res;
		res.vec[0] += v.vec[0];
		res.vec[1] += v.vec[1];
		res.vec[2] += v.vec[2];
		res.vec[3] += v.vec[3];
		return res;
	}
	/// subtract value from all components of vector
	vec4 opBinary(string op : "-")(const vec4 v) const {
		vec4 res;
		res.vec[0] -= v.vec[0];
		res.vec[1] -= v.vec[1];
		res.vec[2] -= v.vec[2];
		res.vec[3] -= v.vec[3];
		return res;
	}
	/// subtract value from all components of vector
	float opBinary(string op : "*")(const vec4 v) const {
		return dot(v);
	}
	/// dot product (sum of by-component products of vector components)
	float dot(vec4 v) const {
		float res = 0.0f;
		res += vec[0] * v.vec[0];
		res += vec[1] * v.vec[1];
		res += vec[2] * v.vec[2];
		res += vec[3] * v.vec[3];
		return res;
	}

	/// sum of squares of all vector components
	@property float magnitudeSquared() {
		return vec[0]*vec[0] + vec[1]*vec[1] + vec[2]*vec[2] + vec[3]*vec[3];
	}

	/// length of vector
	@property float magnitude() {
		return sqrt(magnitudeSquared);
	}

	alias length = magnitude;

	/// normalize vector: make its length == 1
	void normalize() {
		div(length);
	}

	/// returns normalized copy of this vector
	@property vec4 normalized() {
		vec4 res = this;
		res.normalize();
		return res;
	}

}

/// float matrix 4 x 4
struct mat4 {
	float[16] m;

	alias m this;

	this(const ref mat4 v) {
		m[0..15] = v.m[0..15];
	}
	this(const float[16] v) {
		m[0..15] = v[0..15];
	}

	ref mat4 opAssign(const ref mat4 v) {
		m[0..15] = v.m[0..15];
		return this;
	}
	ref mat4 opAssign(const float[16] v) {
		m[0..15] = v[0..15];
		return this;
	}

    void setOrtho(float left, float right, float bottom, float top, float nearPlane, float farPlane)
    {
        // Bail out if the projection volume is zero-sized.
        if (left == right || bottom == top || nearPlane == farPlane)
            return;

        // Construct the projection.
        float width = right - left;
        float invheight = top - bottom;
        float clip = farPlane - nearPlane;
        m[0*4 + 0] = 2.0f / width;
        m[1*4 + 0] = 0.0f;
        m[2*4 + 0] = 0.0f;
        m[3*4 + 0] = -(left + right) / width;
        m[0*4 + 1] = 0.0f;
        m[1*4 + 1] = 2.0f / invheight;
        m[2*4 + 1] = 0.0f;
        m[3*4 + 1] = -(top + bottom) / invheight;
        m[0*4 + 2] = 0.0f;
        m[1*4 + 2] = 0.0f;
        m[2*4 + 2] = -2.0f / clip;
        m[3*4 + 2] = -(nearPlane + farPlane) / clip;
        m[0*4 + 3] = 0.0f;
        m[1*4 + 3] = 0.0f;
        m[2*4 + 3] = 0.0f;
        m[3*4 + 3] = 1.0f;
    }

    void setPerspective(float angle, float aspect, float nearPlane, float farPlane)
    {
        // Bail out if the projection volume is zero-sized.
        if (nearPlane == farPlane || aspect == 0.0f)
            return;

        // Construct the projection.
        float radians = (angle / 2.0f) * PI / 180.0f;
        float sine = sin(radians);
        if (sine == 0.0f)
            return;
        float cotan = cos(radians) / sine;
        float clip = farPlane - nearPlane;
        m[0*4 + 0] = cotan / aspect;
        m[1*4 + 0] = 0.0f;
        m[2*4 + 0] = 0.0f;
        m[3*4 + 0] = 0.0f;
        m[0*4 + 1] = 0.0f;
        m[1*4 + 1] = cotan;
        m[2*4 + 1] = 0.0f;
        m[3*4 + 1] = 0.0f;
        m[0*4 + 2] = 0.0f;
        m[1*4 + 2] = 0.0f;
        m[2*4 + 2] = -(nearPlane + farPlane) / clip;
        m[3*4 + 2] = -(2.0f * nearPlane * farPlane) / clip;
        m[0*4 + 3] = 0.0f;
        m[1*4 + 3] = 0.0f;
        m[2*4 + 3] = -1.0f;
        m[3*4 + 3] = 0.0f;
    }

	/// 2d index by row, col
	ref float opIndex(int y, int x) {
		return m[y*4 + x];
	}

	/// 2d index by row, col
	float opIndex(int y, int x) const {
		return m[y*4 + x];
	}

	/// scalar index by rows then (y*4 + x)
	ref float opIndex(int index) {
		return m[index];
	}

	/// scalar index by rows then (y*4 + x)
	float opIndex(int index) const {
		return m[index];
	}

	/// set to identity
	ref mat4 setIdentity() {
		for (int x = 0; x < 4; x++) {
			for (int y = 0; y < 4; y++) {
				if (x == y)
					m[y * 4 + x] = 1.0f;
				else
					m[y * 4 + x] = 0.0f;
			}
		}
		return this;
	}
	ref mat4 setZero() {
		foreach(ref f; m)
			f = 0.0f;
		return this;
	}
	static mat4 identity() {
		mat4 res;
		return res.setIdentity();
	}
	static mat4 zero() {
		mat4 res;
		return res.setZero();
	}
}


unittest {
	vec3 a, b, c;
	a.clear(5);
	b.clear(2);
	float d = a * b;
	auto r1 = a + b;
	auto r2 = a - b;
	c = a; c += b;
	c = a; c -= b;
	c = a; c *= b;
	c = a; c /= b;
	c += 0.3f;
	c -= 0.3f;
	c *= 0.3f;
	c /= 0.3f;
	a.x += 0.5f;
	a.y += 0.5f;
	a.z += 0.5f;
	auto v = b.vec;
	a = [0.1f, 0.2f, 0.3f];
	a.normalize();
	c = b.normalized;
}

unittest {
	vec4 a, b, c;
	a.clear(5);
	b.clear(2);
	float d = a * b;
	auto r1 = a + b;
	auto r2 = a - b;
	c = a; c += b;
	c = a; c -= b;
	c = a; c *= b;
	c = a; c /= b;
	c += 0.3f;
	c -= 0.3f;
	c *= 0.3f;
	c /= 0.3f;
	a.x += 0.5f;
	a.y += 0.5f;
	a.z += 0.5f;
	auto v = b.vec;
	a = [0.1f, 0.2f, 0.3f, 0.4f];
	a.normalize();
	c = b.normalized;
}

unittest {
	mat4 m;
	m.setIdentity();
	m = [1.0f,2.0f,3.0f,4.0f,5.0f,6.0f,7.0f,8.0f,9.0f,10.0f,11.0f,12.0f,13.0f,14.0f,15.0f,16.0f];
	float r;
	r = m[1, 3];
	m[2, 1] = 0.0f;
}
