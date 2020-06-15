module dlangui.core.math3d;

import std.math;
import std.string : format;

/// 2 dimensional vector
struct vec2 {
    union {
        float[2] vec;
        struct {
            float x;
            float y;
        }
    }
    alias u = x;
    alias v = y;
    /// create with all components filled with specified value
    this(float v) {
        x = v;
        y = v;
    }
    this(float[2] v) {
        vec = v;
    }
    this(float[] v) {
        vec = v[0..2];
    }
    this(float * v) {
        vec = v[0..2];
    }
    this(const vec2 v) {
        vec = v.vec;
    }
    this(float x, float y) {
        vec[0] = x;
        vec[1] = y;
    }
    ref vec2 opAssign(float[2] v) return {
        vec = v;
        return this;
    }
    ref vec2 opAssign(vec2 v) return {
        vec = v.vec;
        return this;
    }
    /// fill all components of vector with specified value
    ref vec2 clear(float v) return {
        vec[0] = vec[1] = v;
        return this;
    }
    /// add value to all components of vector
    ref vec2 add(float v) return {
        vec[0] += v;
        vec[1] += v;
        return this;
    }
    /// multiply all components of vector by value
    ref vec2 mul(float v) return {
        vec[0] *= v;
        vec[1] *= v;
        return this;
    }
    /// subtract value from all components of vector
    ref vec2 sub(float v) return {
        vec[0] -= v;
        vec[1] -= v;
        return this;
    }
    /// divide all components of vector by value
    ref vec2 div(float v) return {
        vec[0] /= v;
        vec[1] /= v;
        return this;
    }
    /// add components of another vector to corresponding components of this vector
    ref vec2 add(vec2 v) return {
        vec[0] += v.vec[0];
        vec[1] += v.vec[1];
        return this;
    }
    /// multiply components of this vector  by corresponding components of another vector
    ref vec2 mul(vec2 v) return {
        vec[0] *= v.vec[0];
        vec[1] *= v.vec[1];
        return this;
    }
    /// subtract components of another vector from corresponding components of this vector
    ref vec2 sub(vec2 v) return {
        vec[0] -= v.vec[0];
        vec[1] -= v.vec[1];
        return this;
    }
    /// divide components of this vector  by corresponding components of another vector
    ref vec2 div(vec2 v) return {
        vec[0] /= v.vec[0];
        vec[1] /= v.vec[1];
        return this;
    }

    /// returns vector rotated 90 degrees counter clockwise
    vec2 rotated90ccw() const {
        return vec2(-y, x);
    }

    /// returns vector rotated 90 degrees clockwise
    vec2 rotated90cw() const {
        return vec2(y, -x);
    }

    /// add value to all components of vector
    vec2 opBinary(string op : "+")(float v) const {
        vec2 res = this;
        res.vec[0] += v;
        res.vec[1] += v;
        return res;
    }
    /// multiply all components of vector by value
    vec2 opBinary(string op : "*")(float v) const {
        vec2 res = this;
        res.vec[0] *= v;
        res.vec[1] *= v;
        return res;
    }
    /// subtract value from all components of vector
    vec2 opBinary(string op : "-")(float v) const {
        vec2 res = this;
        res.vec[0] -= v;
        res.vec[1] -= v;
        return res;
    }
    /// divide all components of vector by value
    vec2 opBinary(string op : "/")(float v) const {
        vec2 res = this;
        res.vec[0] /= v;
        res.vec[1] /= v;
        return res;
    }


    /// add value to all components of vector
    ref vec2 opOpAssign(string op : "+")(float v) return {
        vec[0] += v;
        vec[1] += v;
        return this;
    }
    /// multiply all components of vector by value
    ref vec2 opOpAssign(string op : "*")(float v) return {
        vec[0] *= v;
        vec[1] *= v;
        return this;
    }
    /// subtract value from all components of vector
    ref vec2 opOpAssign(string op : "-")(float v) return {
        vec[0] -= v;
        vec[1] -= v;
        vec[2] -= v;
        return this;
    }
    /// divide all components of vector by value
    ref vec2 opOpAssign(string op : "/")(float v) return {
        vec[0] /= v;
        vec[1] /= v;
        vec[2] /= v;
        return this;
    }

    /// by component add values of corresponding components of other vector
    ref vec2 opOpAssign(string op : "+")(const vec2 v) return {
        vec[0] += v.vec[0];
        vec[1] += v.vec[1];
        return this;
    }
    /// by component multiply values of corresponding components of other vector
    ref vec2 opOpAssign(string op : "*")(const vec2 v) return {
        vec[0] *= v.vec[0];
        vec[1] *= v.vec[1];
        return this;
    }
    /// by component subtract values of corresponding components of other vector
    ref vec2 opOpAssign(string op : "-")(const vec2 v) return {
        vec[0] -= v.vec[0];
        vec[1] -= v.vec[1];
        return this;
    }
    /// by component divide values of corresponding components of other vector
    ref vec2 opOpAssign(string op : "/")(const vec2 v) return {
        vec[0] /= v.vec[0];
        vec[1] /= v.vec[1];
        return this;
    }


    /// add value to all components of vector
    vec2 opBinary(string op : "+")(const vec2 v) const {
        vec2 res = this;
        res.vec[0] += v.vec[0];
        res.vec[1] += v.vec[1];
        return res;
    }
    /// subtract value from all components of vector
    vec2 opBinary(string op : "-")(const vec2 v) const {
        vec2 res = this;
        res.vec[0] -= v.vec[0];
        res.vec[1] -= v.vec[1];
        return res;
    }
    /// subtract value from all components of vector
    float opBinary(string op : "*")(const vec3 v) const {
        return dot(v);
    }
    /// dot product (sum of by-component products of vector components)
    float dot(const vec2 v) const {
        float res = 0.0f;
        res += vec[0] * v.vec[0];
        res += vec[1] * v.vec[1];
        return res;
    }

    /// cross product of 2 vec2 is scalar in Z axis
    float crossProduct(const vec2 v2) const {
        return x * v2.y - y * v2.x;
    }

    /// returns vector with all components which are negative of components for this vector
    vec2 opUnary(string op : "-")() const {
        vec2 ret = this;
        ret.vec[0] = -vec[0];
        ret.vec[1] = -vec[1];
        return ret;
    }


    /// sum of squares of all vector components
    @property float magnitudeSquared() {
        return vec[0]*vec[0] + vec[1]*vec[1];
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
    @property vec2 normalized() {
        vec2 res = this;
        res.normalize();
        return res;
    }
}

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
    //@property ref float x() { return vec[0]; }
    //@property ref float y() { return vec[1]; }
    //@property ref float z() { return vec[2]; }
    alias r = x;
    alias g = y;
    alias b = z;
    /// create with all components filled with specified value
    this(float v) {
        x = y = z = v;
    }
    this(float[3] v) {
        vec = v;
    }
    this(float[] v) {
        vec = v[0..3];
    }
    this(float * v) {
        vec = v[0..3];
    }
    this(const vec3 v) {
        vec = v.vec;
    }
    this(float x, float y, float z) {
        vec[0] = x;
        vec[1] = y;
        vec[2] = z;
    }
    ref vec3 opAssign(float[3] v) return {
        vec = v;
        return this;
    }
    ref vec3 opAssign(vec3 v) return {
        vec = v.vec;
        return this;
    }
    ref vec3 opAssign(float x, float y, float z) return {
        vec[0] = x;
        vec[1] = y;
        vec[2] = z;
        return this;
    }
    /// fill all components of vector with specified value
    ref vec3 clear(float v) return {
        vec[0] = vec[1] = vec[2] = v;
        return this;
    }
    /// add value to all components of vector
    ref vec3 add(float v) return {
        vec[0] += v;
        vec[1] += v;
        vec[2] += v;
        return this;
    }
    /// multiply all components of vector by value
    ref vec3 mul(float v) return {
        vec[0] *= v;
        vec[1] *= v;
        vec[2] *= v;
        return this;
    }
    /// subtract value from all components of vector
    ref vec3 sub(float v) return {
        vec[0] -= v;
        vec[1] -= v;
        vec[2] -= v;
        return this;
    }
    /// divide all components of vector by value
    ref vec3 div(float v) return {
        vec[0] /= v;
        vec[1] /= v;
        vec[2] /= v;
        return this;
    }
    /// add components of another vector to corresponding components of this vector
    ref vec3 add(vec3 v) return {
        vec[0] += v.vec[0];
        vec[1] += v.vec[1];
        vec[2] += v.vec[2];
        return this;
    }
    /// multiply components of this vector  by corresponding components of another vector
    ref vec3 mul(vec3 v) return {
        vec[0] *= v.vec[0];
        vec[1] *= v.vec[1];
        vec[2] *= v.vec[2];
        return this;
    }
    /// subtract components of another vector from corresponding components of this vector
    ref vec3 sub(vec3 v) return {
        vec[0] -= v.vec[0];
        vec[1] -= v.vec[1];
        vec[2] -= v.vec[2];
        return this;
    }
    /// divide components of this vector  by corresponding components of another vector
    ref vec3 div(vec3 v) return {
        vec[0] /= v.vec[0];
        vec[1] /= v.vec[1];
        vec[2] /= v.vec[2];
        return this;
    }

    /// add value to all components of vector
    vec3 opBinary(string op : "+")(float v) const {
        vec3 res = this;
        res.vec[0] += v;
        res.vec[1] += v;
        res.vec[2] += v;
        return res;
    }
    /// multiply all components of vector by value
    vec3 opBinary(string op : "*")(float v) const {
        vec3 res = this;
        res.vec[0] *= v;
        res.vec[1] *= v;
        res.vec[2] *= v;
        return res;
    }
    /// subtract value from all components of vector
    vec3 opBinary(string op : "-")(float v) const {
        vec3 res = this;
        res.vec[0] -= v;
        res.vec[1] -= v;
        res.vec[2] -= v;
        return res;
    }
    /// divide all components of vector by value
    vec3 opBinary(string op : "/")(float v) const {
        vec3 res = this;
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
        vec3 res = this;
        res.vec[0] += v.vec[0];
        res.vec[1] += v.vec[1];
        res.vec[2] += v.vec[2];
        return res;
    }
    /// subtract value from all components of vector
    vec3 opBinary(string op : "-")(const vec3 v) const {
        vec3 res = this;
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

    /// returns vector with all components which are negative of components for this vector
    vec3 opUnary(string op : "-")() const {
        vec3 ret = this;
        ret.vec[0] = -vec[0];
        ret.vec[1] = -vec[1];
        ret.vec[2] = -vec[2];
        return ret;
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

    /// cross product
    static vec3 crossProduct(const vec3 v1, const vec3 v2) {
        return vec3(v1.y * v2.z - v1.z * v2.y,
                    v1.z * v2.x - v1.x * v2.z,
                    v1.x * v2.y - v1.y * v2.x);
    }

    /// multiply vector by matrix
    vec3 opBinary(string op : "*")(const ref mat4 matrix) const
    {
        float xx, yy, zz, ww;
        xx = x * matrix.m[0*4 + 0] +
            y * matrix.m[0*4 + 1] +
            z * matrix.m[0*4 + 2] +
            matrix.m[0*4 + 3];
        yy = x * matrix.m[1*4 + 0] +
            y * matrix.m[1*4 + 1] +
            z * matrix.m[1*4 + 2] +
            matrix.m[1*4 + 3];
        zz = x * matrix.m[2*4 + 0] +
            y * matrix.m[2*4 + 1] +
            z * matrix.m[2*4 + 2] +
            matrix.m[2*4 + 3];
        ww = x * matrix.m[3*4 + 0] +
            y * matrix.m[3*4 + 1] +
            z * matrix.m[3*4 + 2] +
            matrix.m[3*4 + 3];
        if (ww == 1.0f)
            return vec3(xx, yy, zz);
        else
            return vec3(xx / ww, yy / ww, zz / ww);
    }

    @property string toString() {
        return "(%f,%f,%f)".format(x, y, z);
    }
}

/// 4 component vector
struct vec4 {
    union {
        float[4] vec;
        struct {
            float x;
            float y;
            float z;
            float w;
        }
    }
    alias r = x;
    alias g = y;
    alias b = z;
    alias a = w;
    /// create with all components filled with specified value
    this(float v) {
        x = y = z = w = v;
    }
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
        vec[0] = v.vec[0];
        vec[1] = v.vec[1];
        vec[2] = v.vec[2];
        vec[3] = 1.0f;
    }
    ref vec4 opAssign(const float[4] v) return {
        vec = v;
        return this;
    }
    ref vec4 opAssign(const vec4 v) return {
        vec = v.vec;
        return this;
    }
    ref vec4 opAssign(float x, float y, float z, float w) return {
        vec[0] = x;
        vec[1] = y;
        vec[2] = z;
        vec[3] = w;
        return this;
    }
    ref vec4 opAssign(const vec3 v) return {
        vec[0] = v.vec[0];
        vec[1] = v.vec[1];
        vec[2] = v.vec[2];
        vec[3] = 1.0f;
        return this;
    }


    /// fill all components of vector with specified value
    ref vec4 clear(float v) return {
        vec[0] = vec[1] = vec[2] = vec[3] = v;
        return this;
    }
    /// add value to all components of vector
    ref vec4 add(float v) return {
        vec[0] += v;
        vec[1] += v;
        vec[2] += v;
        vec[3] += v;
        return this;
    }
    /// multiply all components of vector by value
    ref vec4 mul(float v) return {
        vec[0] *= v;
        vec[1] *= v;
        vec[2] *= v;
        vec[3] *= v;
        return this;
    }
    /// subtract value from all components of vector
    ref vec4 sub(float v) return {
        vec[0] -= v;
        vec[1] -= v;
        vec[2] -= v;
        vec[3] -= v;
        return this;
    }
    /// divide all components of vector by value
    ref vec4 div(float v) return {
        vec[0] /= v;
        vec[1] /= v;
        vec[2] /= v;
        vec[3] /= v;
        return this;
    }
    /// add components of another vector to corresponding components of this vector
    ref vec4 add(const vec4 v) return {
        vec[0] += v.vec[0];
        vec[1] += v.vec[1];
        vec[2] += v.vec[2];
        vec[3] += v.vec[3];
        return this;
    }
    /// multiply components of this vector  by corresponding components of another vector
    ref vec4 mul(vec4 v) return {
        vec[0] *= v.vec[0];
        vec[1] *= v.vec[1];
        vec[2] *= v.vec[2];
        vec[3] *= v.vec[3];
        return this;
    }
    /// subtract components of another vector from corresponding components of this vector
    ref vec4 sub(vec4 v) return {
        vec[0] -= v.vec[0];
        vec[1] -= v.vec[1];
        vec[2] -= v.vec[2];
        vec[3] -= v.vec[3];
        return this;
    }
    /// divide components of this vector  by corresponding components of another vector
    ref vec4 div(vec4 v) return {
        vec[0] /= v.vec[0];
        vec[1] /= v.vec[1];
        vec[2] /= v.vec[2];
        vec[3] /= v.vec[3];
        return this;
    }

    /// add value to all components of vector
    vec4 opBinary(string op : "+")(float v) const return {
        vec4 res = this;
        res.vec[0] += v;
        res.vec[1] += v;
        res.vec[2] += v;
        res.vec[3] += v;
        return res;
    }
    /// multiply all components of vector by value
    vec4 opBinary(string op : "*")(float v) const return {
        vec4 res = this;
        res.vec[0] *= v;
        res.vec[1] *= v;
        res.vec[2] *= v;
        res.vec[3] *= v;
        return res;
    }
    /// subtract value from all components of vector
    vec4 opBinary(string op : "-")(float v) const return {
        vec4 res = this;
        res.vec[0] -= v;
        res.vec[1] -= v;
        res.vec[2] -= v;
        res.vec[3] -= v;
        return res;
    }
    /// divide all components of vector by value
    vec4 opBinary(string op : "/")(float v) const return {
        vec4 res = this;
        res.vec[0] /= v;
        res.vec[1] /= v;
        res.vec[2] /= v;
        res.vec[3] /= v;
        return res;
    }

    /// add value to all components of vector
    ref vec4 opOpAssign(string op : "+")(float v) return {
        vec[0] += v;
        vec[1] += v;
        vec[2] += v;
        vec[3] += v;
        return this;
    }
    /// multiply all components of vector by value
    ref vec4 opOpAssign(string op : "*")(float v) return {
        vec[0] *= v;
        vec[1] *= v;
        vec[2] *= v;
        vec[3] *= v;
        return this;
    }
    /// subtract value from all components of vector
    ref vec4 opOpAssign(string op : "-")(float v) return {
        vec[0] -= v;
        vec[1] -= v;
        vec[2] -= v;
        vec[3] -= v;
        return this;
    }
    /// divide all components of vector by value
    ref vec4 opOpAssign(string op : "/")(float v) return {
        vec[0] /= v;
        vec[1] /= v;
        vec[2] /= v;
        vec[3] /= v;
        return this;
    }

    /// by component add values of corresponding components of other vector
    ref vec4 opOpAssign(string op : "+")(const vec4 v) return {
        vec[0] += v.vec[0];
        vec[1] += v.vec[1];
        vec[2] += v.vec[2];
        vec[3] += v.vec[3];
        return this;
    }
    /// by component multiply values of corresponding components of other vector
    ref vec4 opOpAssign(string op : "*")(const vec4 v) return {
        vec[0] *= v.vec[0];
        vec[1] *= v.vec[1];
        vec[2] *= v.vec[2];
        vec[3] *= v.vec[3];
        return this;
    }
    /// by component subtract values of corresponding components of other vector
    ref vec4 opOpAssign(string op : "-")(const vec4 v) return {
        vec[0] -= v.vec[0];
        vec[1] -= v.vec[1];
        vec[2] -= v.vec[2];
        vec[3] -= v.vec[3];
        return this;
    }
    /// by component divide values of corresponding components of other vector
    ref vec4 opOpAssign(string op : "/")(const vec4 v) return {
        vec[0] /= v.vec[0];
        vec[1] /= v.vec[1];
        vec[2] /= v.vec[2];
        vec[3] /= v.vec[3];
        return this;
    }



    /// add value to all components of vector
    vec4 opBinary(string op : "+")(const vec4 v) const return {
        vec4 res = this;
        res.vec[0] += v.vec[0];
        res.vec[1] += v.vec[1];
        res.vec[2] += v.vec[2];
        res.vec[3] += v.vec[3];
        return res;
    }
    /// subtract value from all components of vector
    vec4 opBinary(string op : "-")(const vec4 v) const return {
        vec4 res = this;
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

    /// returns vector with all components which are negative of components for this vector
    vec4 opUnary(string op : "-")() const return {
        vec4 ret = this;
        ret[0] = -vec[0];
        ret[1] = -vec[1];
        ret[2] = -vec[2];
        ret[3] = -vec[3];
        return ret;
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
    @property vec4 normalized() return {
        vec4 res = this;
        res.normalize();
        return res;
    }

    /// multiply vector by matrix
    vec4 opBinary(string op : "*")(const ref mat4 matrix) const
    {
        float xx, yy, zz, ww;
        xx = x * matrix.m[0*4 + 0] +
             y * matrix.m[0*4 + 1] +
             z * matrix.m[0*4 + 2] +
             w * matrix.m[0*4 + 3];
        yy = x * matrix.m[1*4 + 0] +
             y * matrix.m[1*4 + 1] +
             z * matrix.m[1*4 + 2] +
             w * matrix.m[1*4 + 3];
        zz = x * matrix.m[2*4 + 0] +
             y * matrix.m[2*4 + 1] +
             z * matrix.m[2*4 + 2] +
             w * matrix.m[2*4 + 3];
        ww = x * matrix.m[3*4 + 0] +
             y * matrix.m[3*4 + 1] +
             z * matrix.m[3*4 + 2] +
             w * matrix.m[3*4 + 3];
        return vec4(xx, yy, zz, ww);
    }

    @property string toString() {
        return "(%f,%f,%f,%f)".format(x, y, z, w);
    }
}

bool fuzzyNull(float v) {
    return v < 0.0000001f && v > -0.0000001f;
}

/// float matrix 4 x 4
struct mat4 {
    float[16] m = [1, 0, 0, 0,  0, 1, 0, 0,  0, 0, 1, 0,  0, 0, 0, 1];

    @property string dump() const {
        import std.conv : to;
        return to!string(m[0..4]) ~ to!string(m[4..8]) ~ to!string(m[8..12]) ~ to!string(m[12..16]);
    }

    //alias m this;

    this(float v) {
        setDiagonal(v);
    }

    this(const ref mat4 v) {
        m[0..16] = v.m[0..16];
    }
    this(const float[16] v) {
        m[0..16] = v[0..16];
    }

    ref mat4 opAssign(const ref mat4 v) return {
        m[0..16] = v.m[0..16];
        return this;
    }
    ref mat4 opAssign(const  mat4 v) return {
        m[0..16] = v.m[0..16];
        return this;
    }
    ref mat4 opAssign(const float[16] v) return {
        m[0..16] = v[0..16];
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
        float radians = (angle / 2.0f) * PI / 180.0f;
        if (nearPlane == farPlane || aspect == 0.0f || radians < 0.0001f)
            return;
        float f = 1 / tan(radians);
        float d = 1 / (nearPlane - farPlane);

        // Construct the projection.
        m[0*4 + 0] = f / aspect;
        m[1*4 + 0] = 0.0f;
        m[2*4 + 0] = 0.0f;
        m[3*4 + 0] = 0.0f;

        m[0*4 + 1] = 0.0f;
        m[1*4 + 1] = f;
        m[2*4 + 1] = 0.0f;
        m[3*4 + 1] = 0.0f;

        m[0*4 + 2] = 0.0f;
        m[1*4 + 2] = 0.0f;
        m[2*4 + 2] = (nearPlane + farPlane) * d;
        m[3*4 + 2] = 2.0f * nearPlane * farPlane * d;

        m[0*4 + 3] = 0.0f;
        m[1*4 + 3] = 0.0f;
        m[2*4 + 3] = -1.0f;
        m[3*4 + 3] = 0.0f;
    }

    ref mat4 lookAt(const vec3 eye, const vec3 center, const vec3 up) return {
        vec3 forward = (center - eye).normalized();
        vec3 side = vec3.crossProduct(forward, up).normalized();
        vec3 upVector = vec3.crossProduct(side, forward);

        mat4 m;
        m.setIdentity();
        m[0*4 + 0] = side.x;
        m[1*4 + 0] = side.y;
        m[2*4 + 0] = side.z;
        m[3*4 + 0] = 0.0f;
        m[0*4 + 1] = upVector.x;
        m[1*4 + 1] = upVector.y;
        m[2*4 + 1] = upVector.z;
        m[3*4 + 1] = 0.0f;
        m[0*4 + 2] = -forward.x;
        m[1*4 + 2] = -forward.y;
        m[2*4 + 2] = -forward.z;
        m[3*4 + 2] = 0.0f;
        m[0*4 + 3] = 0.0f;
        m[1*4 + 3] = 0.0f;
        m[2*4 + 3] = 0.0f;
        m[3*4 + 3] = 1.0f;

        this *= m;
        translate(-eye);
        return this;
    }

    /// transpose matrix
    void transpose() {
        float[16] tmp = [
            m[0], m[4], m[8], m[12],
            m[1], m[5], m[9], m[13],
            m[2], m[6], m[10], m[14],
            m[3], m[7], m[11], m[15]
        ];
        m = tmp;
    }

    mat4 invert() const
    {
        float a0 = m[0] * m[5] - m[1] * m[4];
        float a1 = m[0] * m[6] - m[2] * m[4];
        float a2 = m[0] * m[7] - m[3] * m[4];
        float a3 = m[1] * m[6] - m[2] * m[5];
        float a4 = m[1] * m[7] - m[3] * m[5];
        float a5 = m[2] * m[7] - m[3] * m[6];
        float b0 = m[8] * m[13] - m[9] * m[12];
        float b1 = m[8] * m[14] - m[10] * m[12];
        float b2 = m[8] * m[15] - m[11] * m[12];
        float b3 = m[9] * m[14] - m[10] * m[13];
        float b4 = m[9] * m[15] - m[11] * m[13];
        float b5 = m[10] * m[15] - m[11] * m[14];

        // Calculate the determinant.
        float det = a0 * b5 - a1 * b4 + a2 * b3 + a3 * b2 - a4 * b1 + a5 * b0;

        mat4 inverse;

        // Close to zero, can't invert.
        if (fabs(det) <= 0.00000001f)
            return inverse;

        // Support the case where m == dst.
        inverse.m[0]  = m[5] * b5 - m[6] * b4 + m[7] * b3;
        inverse.m[1]  = -m[1] * b5 + m[2] * b4 - m[3] * b3;
        inverse.m[2]  = m[13] * a5 - m[14] * a4 + m[15] * a3;
        inverse.m[3]  = -m[9] * a5 + m[10] * a4 - m[11] * a3;

        inverse.m[4]  = -m[4] * b5 + m[6] * b2 - m[7] * b1;
        inverse.m[5]  = m[0] * b5 - m[2] * b2 + m[3] * b1;
        inverse.m[6]  = -m[12] * a5 + m[14] * a2 - m[15] * a1;
        inverse.m[7]  = m[8] * a5 - m[10] * a2 + m[11] * a1;

        inverse.m[8]  = m[4] * b4 - m[5] * b2 + m[7] * b0;
        inverse.m[9]  = -m[0] * b4 + m[1] * b2 - m[3] * b0;
        inverse.m[10] = m[12] * a4 - m[13] * a2 + m[15] * a0;
        inverse.m[11] = -m[8] * a4 + m[9] * a2 - m[11] * a0;

        inverse.m[12] = -m[4] * b3 + m[5] * b1 - m[6] * b0;
        inverse.m[13] = m[0] * b3 - m[1] * b1 + m[2] * b0;
        inverse.m[14] = -m[12] * a3 + m[13] * a1 - m[14] * a0;
        inverse.m[15] = m[8] * a3 - m[9] * a1 + m[10] * a0;

        float mul = 1.0f / det;
        inverse *= mul;
        return inverse;
    }

    ref mat4 setLookAt(const vec3 eye, const vec3 center, const vec3 up) return {
        setIdentity();
        lookAt(eye, center, up);
        return this;
    }

    ref mat4 translate(const vec3 v) return {
        m[3*4 + 0] += m[0*4 + 0] * v.x + m[1*4 + 0] * v.y + m[2*4 + 0] * v.z;
        m[3*4 + 1] += m[0*4 + 1] * v.x + m[1*4 + 1] * v.y + m[2*4 + 1] * v.z;
        m[3*4 + 2] += m[0*4 + 2] * v.x + m[1*4 + 2] * v.y + m[2*4 + 2] * v.z;
        m[3*4 + 3] += m[0*4 + 3] * v.x + m[1*4 + 3] * v.y + m[2*4 + 3] * v.z;
        return this;
    }

    ref mat4 translate(float x, float y, float z) return {
        m[3*4 + 0] += m[0*4 + 0] * x + m[1*4 + 0] * y + m[2*4 + 0] * z;
        m[3*4 + 1] += m[0*4 + 1] * x + m[1*4 + 1] * y + m[2*4 + 1] * z;
        m[3*4 + 2] += m[0*4 + 2] * x + m[1*4 + 2] * y + m[2*4 + 2] * z;
        m[3*4 + 3] += m[0*4 + 3] * x + m[1*4 + 3] * y + m[2*4 + 3] * z;
        return this;
    }

    /// add scalar to all items of matrix
    mat4 opBinary(string op : "+")(float v) const {
        foreach(ref item; m)
            item += v;
    }

    /// multiply this matrix by scalar
    mat4 opBinary(string op : "-")(float v) const {
        foreach(ref item; m)
            item -= v;
    }

    /// multiply this matrix by scalar
    mat4 opBinary(string op : "*")(float v) const {
        foreach(ref item; m)
            item *= v;
    }

    /// multiply this matrix by scalar
    mat4 opBinary(string op : "/")(float v) const {
        foreach(ref item; m)
            item /= v;
    }

    /// multiply this matrix by another matrix
    mat4 opBinary(string op : "*")(const ref mat4 m2) const {
        return mul(this, m2);
    }

    /// multiply this matrix by another matrix
    void opOpAssign(string op : "*")(const ref mat4 m2) {
        this = mul(this, m2);
    }

    /// multiply two matrices
    static mat4 mul(const ref mat4 m1, const ref mat4 m2) {
        mat4 m;
        m.m[0*4 + 0] =
            m1.m[0*4 + 0] * m2.m[0*4 + 0] +
            m1.m[1*4 + 0] * m2.m[0*4 + 1] +
            m1.m[2*4 + 0] * m2.m[0*4 + 2] +
            m1.m[3*4 + 0] * m2.m[0*4 + 3];
        m.m[0*4 + 1] =
            m1.m[0*4 + 1] * m2.m[0*4 + 0] +
            m1.m[1*4 + 1] * m2.m[0*4 + 1] +
            m1.m[2*4 + 1] * m2.m[0*4 + 2] +
            m1.m[3*4 + 1] * m2.m[0*4 + 3];
        m.m[0*4 + 2] =
            m1.m[0*4 + 2] * m2.m[0*4 + 0] +
            m1.m[1*4 + 2] * m2.m[0*4 + 1] +
            m1.m[2*4 + 2] * m2.m[0*4 + 2] +
            m1.m[3*4 + 2] * m2.m[0*4 + 3];
        m.m[0*4 + 3] =
            m1.m[0*4 + 3] * m2.m[0*4 + 0] +
            m1.m[1*4 + 3] * m2.m[0*4 + 1] +
            m1.m[2*4 + 3] * m2.m[0*4 + 2] +
            m1.m[3*4 + 3] * m2.m[0*4 + 3];
        m.m[1*4 + 0] =
            m1.m[0*4 + 0] * m2.m[1*4 + 0] +
            m1.m[1*4 + 0] * m2.m[1*4 + 1] +
            m1.m[2*4 + 0] * m2.m[1*4 + 2] +
            m1.m[3*4 + 0] * m2.m[1*4 + 3];
        m.m[1*4 + 1] =
            m1.m[0*4 + 1] * m2.m[1*4 + 0] +
            m1.m[1*4 + 1] * m2.m[1*4 + 1] +
            m1.m[2*4 + 1] * m2.m[1*4 + 2] +
            m1.m[3*4 + 1] * m2.m[1*4 + 3];
        m.m[1*4 + 2] =
            m1.m[0*4 + 2] * m2.m[1*4 + 0] +
            m1.m[1*4 + 2] * m2.m[1*4 + 1] +
            m1.m[2*4 + 2] * m2.m[1*4 + 2] +
            m1.m[3*4 + 2] * m2.m[1*4 + 3];
        m.m[1*4 + 3] =
            m1.m[0*4 + 3] * m2.m[1*4 + 0] +
            m1.m[1*4 + 3] * m2.m[1*4 + 1] +
            m1.m[2*4 + 3] * m2.m[1*4 + 2] +
            m1.m[3*4 + 3] * m2.m[1*4 + 3];
        m.m[2*4 + 0] =
            m1.m[0*4 + 0] * m2.m[2*4 + 0] +
            m1.m[1*4 + 0] * m2.m[2*4 + 1] +
            m1.m[2*4 + 0] * m2.m[2*4 + 2] +
            m1.m[3*4 + 0] * m2.m[2*4 + 3];
        m.m[2*4 + 1] =
            m1.m[0*4 + 1] * m2.m[2*4 + 0] +
            m1.m[1*4 + 1] * m2.m[2*4 + 1] +
            m1.m[2*4 + 1] * m2.m[2*4 + 2] +
            m1.m[3*4 + 1] * m2.m[2*4 + 3];
        m.m[2*4 + 2] =
            m1.m[0*4 + 2] * m2.m[2*4 + 0] +
            m1.m[1*4 + 2] * m2.m[2*4 + 1] +
            m1.m[2*4 + 2] * m2.m[2*4 + 2] +
            m1.m[3*4 + 2] * m2.m[2*4 + 3];
        m.m[2*4 + 3] =
            m1.m[0*4 + 3] * m2.m[2*4 + 0] +
            m1.m[1*4 + 3] * m2.m[2*4 + 1] +
            m1.m[2*4 + 3] * m2.m[2*4 + 2] +
            m1.m[3*4 + 3] * m2.m[2*4 + 3];
        m.m[3*4 + 0] =
            m1.m[0*4 + 0] * m2.m[3*4 + 0] +
            m1.m[1*4 + 0] * m2.m[3*4 + 1] +
            m1.m[2*4 + 0] * m2.m[3*4 + 2] +
            m1.m[3*4 + 0] * m2.m[3*4 + 3];
        m.m[3*4 + 1] =
            m1.m[0*4 + 1] * m2.m[3*4 + 0] +
            m1.m[1*4 + 1] * m2.m[3*4 + 1] +
            m1.m[2*4 + 1] * m2.m[3*4 + 2] +
            m1.m[3*4 + 1] * m2.m[3*4 + 3];
        m.m[3*4 + 2] =
            m1.m[0*4 + 2] * m2.m[3*4 + 0] +
            m1.m[1*4 + 2] * m2.m[3*4 + 1] +
            m1.m[2*4 + 2] * m2.m[3*4 + 2] +
            m1.m[3*4 + 2] * m2.m[3*4 + 3];
        m.m[3*4 + 3] =
            m1.m[0*4 + 3] * m2.m[3*4 + 0] +
            m1.m[1*4 + 3] * m2.m[3*4 + 1] +
            m1.m[2*4 + 3] * m2.m[3*4 + 2] +
            m1.m[3*4 + 3] * m2.m[3*4 + 3];
        return m;
    }

    /// multiply matrix by vec3
    vec3 opBinary(string op : "*")(const vec3 vector) const
    {
        float x, y, z, w;
        x = vector.x * m[0*4 + 0] +
            vector.y * m[1*4 + 0] +
            vector.z * m[2*4 + 0] +
            m[3*4 + 0];
        y = vector.x * m[0*4 + 1] +
            vector.y * m[1*4 + 1] +
            vector.z * m[2*4 + 1] +
            m[3*4 + 1];
        z = vector.x * m[0*4 + 2] +
            vector.y * m[1*4 + 2] +
            vector.z * m[2*4 + 2] +
            m[3*4 + 2];
        w = vector.x * m[0*4 + 3] +
            vector.y * m[1*4 + 3] +
            vector.z * m[2*4 + 3] +
            m[3*4 + 3];
        if (w == 1.0f)
            return vec3(x, y, z);
        else
            return vec3(x / w, y / w, z / w);
    }

    /// multiply matrix by vec4
    vec4 opBinary(string op : "*")(const vec4 vector) const
    {
        float x, y, z, w;
        x = vector.x * m[0*4 + 0] +
            vector.y * m[1*4 + 0] +
            vector.z * m[2*4 + 0] +
            vector.w * m[3*4 + 0];
        y = vector.x * m[0*4 + 1] +
            vector.y * m[1*4 + 1] +
            vector.z * m[2*4 + 1] +
            vector.w * m[3*4 + 1];
        z = vector.x * m[0*4 + 2] +
            vector.y * m[1*4 + 2] +
            vector.z * m[2*4 + 2] +
            vector.w * m[3*4 + 2];
        w = vector.x * m[0*4 + 3] +
            vector.y * m[1*4 + 3] +
            vector.z * m[2*4 + 3] +
            vector.w * m[3*4 + 3];
        return vec4(x, y, z, w);
    }

    /// 2d index by row, col
    ref float opIndex(int y, int x) return {
        return m[y*4 + x];
    }

    /// 2d index by row, col
    float opIndex(int y, int x) const return {
        return m[y*4 + x];
    }

    /// scalar index by rows then (y*4 + x)
    ref float opIndex(int index) return {
        return m[index];
    }

    /// scalar index by rows then (y*4 + x)
    float opIndex(int index) const return {
        return m[index];
    }

    /// set to identity: fill all items of matrix with zero except main diagonal items which will be assigned to 1.0f
    ref mat4 setIdentity() return {
        return setDiagonal(1.0f);
    }
    /// set to diagonal: fill all items of matrix with zero except main diagonal items which will be assigned to v
    ref mat4 setDiagonal(float v) return {
        for (int x = 0; x < 4; x++) {
            for (int y = 0; y < 4; y++) {
                if (x == y)
                    m[y * 4 + x] = v;
                else
                    m[y * 4 + x] = 0.0f;
            }
        }
        return this;
    }
    /// fill all items of matrix with specified value
    ref mat4 fill(float v) return {
        foreach(ref f; m)
            f = v;
        return this;
    }
    /// fill all items of matrix with zero
    ref mat4 setZero() return {
        foreach(ref f; m)
            f = 0.0f;
        return this;
    }
    /// creates identity matrix
    static mat4 identity() {
        mat4 res;
        return res.setIdentity();
    }
    /// creates zero matrix
    static mat4 zero() {
        mat4 res;
        return res.setZero();
    }


    /// add value to all components of matrix
    void opOpAssign(string op : "+")(float v) {
        foreach(ref item; m)
            item += v;
    }
    /// multiply all components of matrix by value
    void opOpAssign(string op : "*")(float v) {
        foreach(ref item; m)
            item *= v;
    }
    /// subtract value from all components of matrix
    void opOpAssign(string op : "-")(float v) {
        foreach(ref item; m)
            item -= v;
    }
    /// divide all components of vector by matrix
    void opOpAssign(string op : "/")(float v) {
        foreach(ref item; m)
            item /= v;
    }

    /// inplace rotate around Z axis
    ref mat4 rotatez(float angle) return {
        return rotate(angle, 0, 0, 1);
    }

    /// inplace rotate around X axis
    ref mat4 rotatex(float angle) return {
        return rotate(angle, 1, 0, 0);
    }

    /// inplace rotate around Y axis
    ref mat4 rotatey(float angle) return {
        return rotate(angle, 0, 1, 0);
    }

    ref mat4 rotate(float angle, const vec3 axis) return {
        return rotate(angle, axis.x, axis.y, axis.z);
    }

    ref mat4 rotate(float angle, float x, float y, float z) return {
        if (angle == 0.0f)
            return this;
        mat4 m;
        float c, s, ic;
        if (angle == 90.0f || angle == -270.0f) {
            s = 1.0f;
            c = 0.0f;
        } else if (angle == -90.0f || angle == 270.0f) {
            s = -1.0f;
            c = 0.0f;
        } else if (angle == 180.0f || angle == -180.0f) {
            s = 0.0f;
            c = -1.0f;
        } else {
            float a = angle * PI / 180.0f;
            c = cos(a);
            s = sin(a);
        }
        bool quick = false;
        if (x == 0.0f) {
            if (y == 0.0f) {
                if (z != 0.0f) {
                    // Rotate around the Z axis.
                    m.setIdentity();
                    m.m[0*4 + 0] = c;
                    m.m[1*4 + 1] = c;
                    if (z < 0.0f) {
                        m.m[1*4 + 0] = s;
                        m.m[0*4 + 1] = -s;
                    } else {
                        m.m[1*4 + 0] = -s;
                        m.m[0*4 + 1] = s;
                    }
                    quick = true;
                }
            } else if (z == 0.0f) {
                // Rotate around the Y axis.
                m.setIdentity();
                m.m[0*4 + 0] = c;
                m.m[2*4 + 2] = c;
                if (y < 0.0f) {
                    m.m[2*4 + 0] = -s;
                    m.m[0*4 + 2] = s;
                } else {
                    m.m[2*4 + 0] = s;
                    m.m[0*4 + 2] = -s;
                }
                quick = true;
            }
        } else if (y == 0.0f && z == 0.0f) {
            // Rotate around the X axis.
            m.setIdentity();
            m.m[1*4 + 1] = c;
            m.m[2*4 + 2] = c;
            if (x < 0.0f) {
                m.m[2*4 + 1] = s;
                m.m[1*4 + 2] = -s;
            } else {
                m.m[2*4 + 1] = -s;
                m.m[1*4 + 2] = s;
            }
            quick = true;
        }
        if (!quick) {
            float len = x * x + y * y + z * z;
            if (!fuzzyNull(len - 1.0f) && !fuzzyNull(len)) {
                len = sqrt(len);
                x /= len;
                y /= len;
                z /= len;
            }
            ic = 1.0f - c;
            m.m[0*4 + 0] = x * x * ic + c;
            m.m[1*4 + 0] = x * y * ic - z * s;
            m.m[2*4 + 0] = x * z * ic + y * s;
            m.m[3*4 + 0] = 0.0f;
            m.m[0*4 + 1] = y * x * ic + z * s;
            m.m[1*4 + 1] = y * y * ic + c;
            m.m[2*4 + 1] = y * z * ic - x * s;
            m.m[3*4 + 1] = 0.0f;
            m.m[0*4 + 2] = x * z * ic - y * s;
            m.m[1*4 + 2] = y * z * ic + x * s;
            m.m[2*4 + 2] = z * z * ic + c;
            m.m[3*4 + 2] = 0.0f;
            m.m[0*4 + 3] = 0.0f;
            m.m[1*4 + 3] = 0.0f;
            m.m[2*4 + 3] = 0.0f;
            m.m[3*4 + 3] = 1.0f;
        }
        this *= m;
        return this;
    }

    ref mat4 rotateX(float angle) return {
        return rotate(angle, 1, 0, 0);
    }

    ref mat4 rotateY(float angle) return {
        return rotate(angle, 0, 1, 0);
    }

    ref mat4 rotateZ(float angle) return {
        return rotate(angle, 0, 0, 1);
    }

    ref mat4 scale(float x, float y, float z) return {
        m[0*4 + 0] *= x;
        m[0*4 + 1] *= x;
        m[0*4 + 2] *= x;
        m[0*4 + 3] *= x;
        m[1*4 + 0] *= y;
        m[1*4 + 1] *= y;
        m[1*4 + 2] *= y;
        m[1*4 + 3] *= y;
        m[2*4 + 0] *= z;
        m[2*4 + 1] *= z;
        m[2*4 + 2] *= z;
        m[2*4 + 3] *= z;
        return this;
    }

    ref mat4 scale(float v) return {
        m[0*4 + 0] *= v;
        m[0*4 + 1] *= v;
        m[0*4 + 2] *= v;
        m[0*4 + 3] *= v;
        m[1*4 + 0] *= v;
        m[1*4 + 1] *= v;
        m[1*4 + 2] *= v;
        m[1*4 + 3] *= v;
        m[2*4 + 0] *= v;
        m[2*4 + 1] *= v;
        m[2*4 + 2] *= v;
        m[2*4 + 3] *= v;
        //m[3*4 + 0] *= v;
        //m[3*4 + 1] *= v;
        //m[3*4 + 2] *= v;
        //m[3*4 + 3] *= v;
        return this;
    }

    ref mat4 scale(const vec3 v) return {
        m[0*4 + 0] *= v.x;
        m[0*4 + 1] *= v.x;
        m[0*4 + 2] *= v.x;
        m[0*4 + 3] *= v.x;
        m[1*4 + 0] *= v.y;
        m[1*4 + 1] *= v.y;
        m[1*4 + 2] *= v.y;
        m[1*4 + 3] *= v.y;
        m[2*4 + 0] *= v.z;
        m[2*4 + 1] *= v.z;
        m[2*4 + 2] *= v.z;
        m[2*4 + 3] *= v.z;
        return this;
    }

    static mat4 translation(float x, float y, float z) {
        // TODO
        mat4 res = 1;
        return res;
    }

    /**
    * Decomposes the scale, rotation and translation components of this matrix.
    *
    * @param scale The scale.
    * @param rotation The rotation.
    * @param translation The translation.
    */
    bool decompose(vec3 * scale, vec4 * rotation, vec3 * translation) const {
        if (translation)
        {
            // Extract the translation.
            translation.x = m[12];
            translation.y = m[13];
            translation.z = m[14];
        }

        // Nothing left to do.
        if (!scale && !rotation)
            return true;

        // Extract the scale.
        // This is simply the length of each axis (row/column) in the matrix.
        vec3 xaxis = vec3(m[0], m[1], m[2]);
        float scaleX = xaxis.length();

        vec3 yaxis = vec3(m[4], m[5], m[6]);
        float scaleY = yaxis.length();

        vec3 zaxis = vec3(m[8], m[9], m[10]);
        float scaleZ = zaxis.length();

        // Determine if we have a negative scale (true if determinant is less than zero).
        // In this case, we simply negate a single axis of the scale.
        float det = determinant();
        if (det < 0)
            scaleZ = -scaleZ;

        if (scale)
        {
            scale.x = scaleX;
            scale.y = scaleY;
            scale.z = scaleZ;
        }

        // Nothing left to do.
        if (!rotation)
            return true;

        //// Scale too close to zero, can't decompose rotation.
        //if (scaleX < MATH_TOLERANCE || scaleY < MATH_TOLERANCE || fabs(scaleZ) < MATH_TOLERANCE)
        //    return false;
        // TODO: support rotation
        return false;
    }

    /**
    * Gets the translational component of this matrix in the specified vector.
    *
    * @param translation A vector to receive the translation.
    */
    void getTranslation(ref vec3 translation) const
    {
        decompose(null, null, &translation);
    }

    @property float determinant() const
    {
        float a0 = m[0] * m[5] - m[1] * m[4];
        float a1 = m[0] * m[6] - m[2] * m[4];
        float a2 = m[0] * m[7] - m[3] * m[4];
        float a3 = m[1] * m[6] - m[2] * m[5];
        float a4 = m[1] * m[7] - m[3] * m[5];
        float a5 = m[2] * m[7] - m[3] * m[6];
        float b0 = m[8] * m[13] - m[9] * m[12];
        float b1 = m[8] * m[14] - m[10] * m[12];
        float b2 = m[8] * m[15] - m[11] * m[12];
        float b3 = m[9] * m[14] - m[10] * m[13];
        float b4 = m[9] * m[15] - m[11] * m[13];
        float b5 = m[10] * m[15] - m[11] * m[14];
        // Calculate the determinant.
        return (a0 * b5 - a1 * b4 + a2 * b3 + a3 * b2 - a4 * b1 + a5 * b0);
    }

    @property vec3 forwardVector() const
    {
        return vec3(-m[8], -m[9], -m[10]);
    }

    @property vec3 backVector() const
    {
        return vec3(m[8], m[9], m[10]);
    }

    void transformVector(ref vec3 v) const {
        transformVector(v.x, v.y, v.z, 0, v);
    }

    void transformPoint(ref vec3 v) const {
        transformVector(v.x, v.y, v.z, 1, v);
    }

    void transformVector(float x, float y, float z, float w, ref vec3 dst) const {
        dst.x = x * m[0] + y * m[4] + z * m[8] + w * m[12];
        dst.y = x * m[1] + y * m[5] + z * m[9] + w * m[13];
        dst.z = x * m[2] + y * m[6] + z * m[10] + w * m[14];
    }

    static __gshared const mat4 IDENTITY;
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
    m += 1;
    m -= 2;
    m *= 3;
    m /= 3;
    m.translate(vec3(2, 3, 4));
    m.translate(5, 6, 7);
    m.lookAt(vec3(5, 5, 5), vec3(0, 0, 0), vec3(-1, 1, 1));
    m.setLookAt(vec3(5, 5, 5), vec3(0, 0, 0), vec3(-1, 1, 1));
    m.scale(2,3,4);
    m.scale(vec3(2,3,4));

    vec3 vv1 = vec3(1,2,3);
    auto p1 = m * vv1;
    vec3 vv2 = vec3(3,4,5);
    auto p2 = vv2 * m;
    auto p3 = vec4(1,2,3,4) * m;
    auto p4 = m * vec4(1,2,3,4);

    m.rotate(30, 1, 1, 1);
    m.rotateX(10);
    m.rotateY(10);
    m.rotateZ(10);
}

/// calculate normal for triangle
vec3 triangleNormal(vec3 p1, vec3 p2, vec3 p3) {
    return vec3.crossProduct(p2 - p1, p3 - p2).normalized();
}

/// calculate normal for triangle
vec3 triangleNormal(float[3] p1, float[3] p2, float[3] p3) {
    return vec3.crossProduct(vec3(p2) - vec3(p1), vec3(p3) - vec3(p2)).normalized();
}

/// Alias for 2d float point
alias PointF = vec2;




// this form can be used within shaders
/// cubic bezier curve
PointF bezierCubic(const PointF[] cp, float t) pure @nogc @safe
    in { assert(cp.length > 3); } do
{
    // control points
    auto p0 = cp[0];
    auto p1 = cp[1];
    auto p2 = cp[2];
    auto p3 = cp[3];

    float u1 = (1.0 - t);
    float u2 = t * t;
    // the polynomials
    float b3 = u2 * t;
    float b2 = 3.0 * u2 * u1;
    float b1 = 3.0 * t * u1 * u1;
    float b0 = u1 * u1 * u1;
    // cubic bezier interpolation
    PointF p = p0 * b0 + p1 * b1 + p2 * b2 + p3 * b3;
    return p;
}

/// quadratic bezier curve (not tested)
PointF bezierQuadratic(const PointF[] cp, float t) pure @nogc @safe
    in { assert(cp.length > 2); } do
{
    auto p0 = cp[0];
    auto p1 = cp[1];
    auto p2 = cp[2];

    float u1 = (1.0 - t);
    float u2 = u1 * u1;

    float b2 = t * t;
    float b1 = 2.0 * u1 * t;
    float b0 = u2;

    PointF p = p0 * b0 + p1 * b1 + p2 * b2;
    return p;
}

/// cubic bezier (first) derivative
PointF bezierCubicDerivative(const PointF[] cp, float t) pure @nogc @safe 
    in { assert(cp.length > 3); } do 
{
    auto p0 = cp[0];
    auto p1 = cp[1];
    auto p2 = cp[2];
    auto p3 = cp[3];

    float u1 = (1.0 - t);
    float u2 = t * t;
    float u3 = 6*(u1)*t;
    float d0 = 3 * u1 * u1;
    // -3*P0*(1-t)^2 + P1*(3*(1-t)^2 - 6*(1-t)*t) + P2*(6*(1-t)*t - 3*t^2) + 3*P3*t^2
    PointF d = p0*(-d0) + p1*(d0 - u3) + p2*(u3 - 3*u2) + (p3*3)*u2;
    return d;
}

/// quadratic bezier (first) derivative
PointF bezierQuadraticDerivative(const PointF[] cp, float t) pure @nogc @safe 
    in { assert(cp.length > 2); } do 
{
    auto p0 = cp[0];
    auto p1 = cp[1];
    auto p2 = cp[2];

    float u1 = (1.0 - t);
    // -2*(1-t)*(p1-p0) + 2*t*(p2-p1);
    PointF d = (p0-p1)*-2*u1 + (p2-p1)*2*t;
    return d;
}

// can't be pure due to normalize & vec2 ctor
/// evaluates cubic bezier direction(tangent) at point t
PointF bezierCubicDirection(const PointF[] cp, float t) {
    auto d = bezierCubicDerivative(cp,t);
    d.normalize();
    return PointF(tan(d.x), tan(d.y));
}

/// evaluates quadratic bezier direction(tangent) at point t
PointF bezierQuadraticDirection(const PointF[] cp, float t) {
    auto d = bezierQuadraticDerivative(cp,t);
    d.normalize();
    return PointF(tan(d.x), tan(d.y));
}

/// templated version of bezier flatten curve function, allocates temporary buffer
PointF[] flattenBezier(alias BezierFunc)(const PointF[] cp, int segmentCountInclusive) 
    if (is(typeof(BezierFunc)==function)) 
{
    if (segmentCountInclusive < 2)
        return PointF[].init;
    PointF[] coords = new PointF[segmentCountInclusive+1];
    flattenBezier!BezierFunc(cp, segmentCountInclusive, coords);
    return coords;
}

/// flatten bezier curve function, writes to provided buffer instead of allocation
void flattenBezier(alias BezierFunc)(const PointF[] cp, int segmentCountInclusive, PointF[] outSegments)
    if (is(typeof(BezierFunc)==function)) 
{
    if (segmentCountInclusive < 2)
        return;
    float step = 1f/segmentCountInclusive;
    outSegments[0] = BezierFunc(cp, 0);
    foreach(i; 1..segmentCountInclusive) {
        outSegments[i] = BezierFunc(cp, i*step);
    }
    outSegments[segmentCountInclusive] = BezierFunc(cp, 1f);
}


/// flattens cubic bezier curve, returns PointF[segmentCount+1] array or empty array if <1 segments
PointF[] flattenBezierCubic(const PointF[] cp, int segmentCount) {
    return flattenBezier!bezierCubic(cp,segmentCount);
}

/// flattens quadratic bezier curve, returns PointF[segmentCount+1] array or empty array if <1 segments
PointF[] flattenBezierQuadratic(const PointF[] cp, int segmentCount) {
    return flattenBezier!bezierQuadratic(cp, segmentCount);
}

/// calculates normal vector at point t using direction
PointF bezierCubicNormal(const PointF[] cp, float t) {
    auto d = bezierCubicDirection(cp, t);
    return d.rotated90ccw;
}

/// calculates normal vector at point t using direction
PointF bezierQuadraticNormal(const PointF[] cp, float t) {
    auto d = bezierQuadraticDerivative(cp, t);
    return d.rotated90ccw;
}
