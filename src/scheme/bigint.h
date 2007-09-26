
#ifndef SCHEME_BIGINT
#define SCHEME_BIGINT

#include <vector>
#include <string>
#include <ostream>

// The code asserts int is 32 bits
// http://cs.marlboro.edu/term/cs-fall02/algorithms/crypto/RSA/bigint/
class BigInt 
{

    friend std::ostream & operator<< (std::ostream &os, const BigInt &b);

    public:        
        BigInt(int32_t n);
        BigInt(std::string str, uint radix = 10);
        BigInt(const BigInt& o);
        
        bool fitsInt64() const;
        int64_t toInt64() const;
        bool fitsInt32() const;
        int32_t toInt32() const;
        std::string toString(uint radix = 10) const;

        BigInt operator+(const BigInt &b) const;
        BigInt operator+(int32_t n) const;
        BigInt& operator+=(const BigInt &b);
        BigInt& operator+=(int32_t n);
        BigInt operator-(const BigInt &b) const;
        BigInt operator-(int32_t n) const;
        BigInt& operator-=(const BigInt &b);
        BigInt& operator-=(int32_t n);
        BigInt operator-() const;
        BigInt operator*(const BigInt &b) const;
        BigInt operator*(int32_t n) const;
        BigInt& operator*=(int32_t n);
        BigInt operator/(int32_t n) const;
        BigInt operator/(const BigInt &b) const;
        int32_t operator%(int32_t n) const;
        bool operator==(const BigInt& o) const;
        bool operator!=(const BigInt& o) const;
        bool operator<(const BigInt& o) const;
        bool operator>(const BigInt& o) const;
        bool operator<=(const BigInt& o) const;
        bool operator>=(const BigInt& o) const;
        
        BigInt abs() const;
        BigInt sqrt() const;
        BigInt expt(int power) const;
        
        bool is_zero() const;
        bool is_one() const;
	int sizeInBits() const;
        void dump() const;
        
    public:
        static const BigInt& ZERO;
        static const BigInt& ONE;
        static const BigInt& TWO;
        
    private:
        static BigInt _ZERO;
        static BigInt _ONE;
        static BigInt _TWO;
        static int64_t RADIX;
    
    private:
        void normalize();
        static int compare(const BigInt& b1, const BigInt& b2); 
        void resize(int32_t new_digits_num);
        int32_t size() const;

    private:        
        std::vector<int64_t> digits;    
        int sign;     
};

#endif

inline
int32_t BigInt::size() const {
    return digits.size();        
}