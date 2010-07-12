#include <unittest/unittest.h>
#include <thrust/unique.h>
#include <thrust/functional.h>

template<typename T>
struct is_equal_div_10_unique
{
    __host__ __device__
    bool operator()(const T x, const T& y) const { return ((int) x / 10) == ((int) y / 10); }
};

template <typename Vector>
void initialize_keys(Vector& keys)
{
    keys.resize(9);
    keys[0] = 11;
    keys[1] = 11;
    keys[2] = 21;
    keys[3] = 20;
    keys[4] = 21;
    keys[5] = 21;
    keys[6] = 21;
    keys[7] = 37;
    keys[8] = 37;
}

template <typename Vector>
void initialize_values(Vector& values)
{
    values.resize(9);
    values[0] = 0; 
    values[1] = 1;
    values[2] = 2;
    values[3] = 3;
    values[4] = 4;
    values[5] = 5;
    values[6] = 6;
    values[7] = 7;
    values[8] = 8;
}


template<typename Vector>
void TestUniqueByKeySimple(void)
{
    typedef typename Vector::value_type T;

    Vector keys;
    Vector values;

    typename thrust::pair<typename Vector::iterator, typename Vector::iterator> new_last;

    // basic test
    initialize_keys(keys);  initialize_values(values);

    new_last = thrust::unique_by_key(keys.begin(), keys.end(), values.begin());

    ASSERT_EQUAL(new_last.first  - keys.begin(),   5);
    ASSERT_EQUAL(new_last.second - values.begin(), 5);
    ASSERT_EQUAL(keys[0], 11);
    ASSERT_EQUAL(keys[1], 21);
    ASSERT_EQUAL(keys[2], 20);
    ASSERT_EQUAL(keys[3], 21);
    ASSERT_EQUAL(keys[4], 37);
    
    ASSERT_EQUAL(values[0], 0);
    ASSERT_EQUAL(values[1], 2);
    ASSERT_EQUAL(values[2], 3);
    ASSERT_EQUAL(values[3], 4);
    ASSERT_EQUAL(values[4], 7);

    // test BinaryPredicate
    initialize_keys(keys);  initialize_values(values);
    
    new_last = thrust::unique_by_key(keys.begin(), keys.end(), values.begin(), is_equal_div_10_unique<T>());

    ASSERT_EQUAL(new_last.first  - keys.begin(),   3);
    ASSERT_EQUAL(new_last.second - values.begin(), 3);
    ASSERT_EQUAL(keys[0], 11);
    ASSERT_EQUAL(keys[1], 21);
    ASSERT_EQUAL(keys[2], 37);
    
    ASSERT_EQUAL(values[0], 0);
    ASSERT_EQUAL(values[1], 2);
    ASSERT_EQUAL(values[2], 7);
}
DECLARE_VECTOR_UNITTEST(TestUniqueByKeySimple);


template<typename Vector>
void TestUniqueCopyByKeySimple(void)
{
    typedef typename Vector::value_type T;

    Vector keys;
    Vector values;

    typename thrust::pair<typename Vector::iterator, typename Vector::iterator> new_last;

    // basic test
    initialize_keys(keys);  initialize_values(values);

    Vector output_keys(keys.size());
    Vector output_values(values.size());

    new_last = thrust::unique_copy_by_key(keys.begin(), keys.end(), values.begin(), output_keys.begin(), output_values.begin());

    ASSERT_EQUAL(new_last.first  - output_keys.begin(),   5);
    ASSERT_EQUAL(new_last.second - output_values.begin(), 5);
    ASSERT_EQUAL(output_keys[0], 11);
    ASSERT_EQUAL(output_keys[1], 21);
    ASSERT_EQUAL(output_keys[2], 20);
    ASSERT_EQUAL(output_keys[3], 21);
    ASSERT_EQUAL(output_keys[4], 37);
    
    ASSERT_EQUAL(output_values[0], 0);
    ASSERT_EQUAL(output_values[1], 2);
    ASSERT_EQUAL(output_values[2], 3);
    ASSERT_EQUAL(output_values[3], 4);
    ASSERT_EQUAL(output_values[4], 7);

    // test BinaryPredicate
    initialize_keys(keys);  initialize_values(values);
    
    new_last = thrust::unique_copy_by_key(keys.begin(), keys.end(), values.begin(), output_keys.begin(), output_values.begin(), is_equal_div_10_unique<T>());

    ASSERT_EQUAL(new_last.first  - output_keys.begin(),   3);
    ASSERT_EQUAL(new_last.second - output_values.begin(), 3);
    ASSERT_EQUAL(output_keys[0], 11);
    ASSERT_EQUAL(output_keys[1], 21);
    ASSERT_EQUAL(output_keys[2], 37);
    
    ASSERT_EQUAL(output_values[0], 0);
    ASSERT_EQUAL(output_values[1], 2);
    ASSERT_EQUAL(output_values[2], 7);
}
DECLARE_VECTOR_UNITTEST(TestUniqueCopyByKeySimple);


template<typename K>
struct TestUniqueByKey
{
    void operator()(const size_t n)
    {
        typedef unsigned int V; // ValueType

        thrust::host_vector<K>   h_keys = unittest::random_integers<bool>(n);
        thrust::host_vector<V>   h_vals = unittest::random_integers<V>(n);
        thrust::device_vector<K> d_keys = h_keys;
        thrust::device_vector<V> d_vals = h_vals;

        typedef typename thrust::host_vector<K>::iterator   HostKeyIterator;
        typedef typename thrust::host_vector<V>::iterator   HostValIterator;
        typedef typename thrust::device_vector<K>::iterator DeviceKeyIterator;
        typedef typename thrust::device_vector<V>::iterator DeviceValIterator;

        typedef typename thrust::pair<HostKeyIterator,  HostValIterator>   HostIteratorPair;
        typedef typename thrust::pair<DeviceKeyIterator,DeviceValIterator> DeviceIteratorPair;

        HostIteratorPair   h_last = thrust::unique_by_key(h_keys.begin(), h_keys.end(), h_vals.begin());
        DeviceIteratorPair d_last = thrust::unique_by_key(d_keys.begin(), d_keys.end(), d_vals.begin());

        ASSERT_EQUAL(h_last.first  - h_keys.begin(), d_last.first  - d_keys.begin());
        ASSERT_EQUAL(h_last.second - h_vals.begin(), d_last.second - d_vals.begin());
       
        size_t N = h_last.first - h_keys.begin();

        h_keys.resize(N);
        h_vals.resize(N);
        d_keys.resize(N);
        d_vals.resize(N);

        ASSERT_EQUAL(h_keys, d_keys);
        ASSERT_EQUAL(h_vals, d_vals);
    }
};
VariableUnitTest<TestUniqueByKey, IntegralTypes> TestUniqueByKeyInstance;


template<typename K>
struct TestUniqueCopyByKey
{
    void operator()(const size_t n)
    {
        typedef unsigned int V; // ValueType

        thrust::host_vector<K>   h_keys = unittest::random_integers<bool>(n);
        thrust::host_vector<V>   h_vals = unittest::random_integers<V>(n);
        thrust::device_vector<K> d_keys = h_keys;
        thrust::device_vector<V> d_vals = h_vals;

        thrust::host_vector<K>   h_keys_output(n);
        thrust::host_vector<V>   h_vals_output(n);
        thrust::device_vector<K> d_keys_output(n);
        thrust::device_vector<V> d_vals_output(n);

        typedef typename thrust::host_vector<K>::iterator   HostKeyIterator;
        typedef typename thrust::host_vector<V>::iterator   HostValIterator;
        typedef typename thrust::device_vector<K>::iterator DeviceKeyIterator;
        typedef typename thrust::device_vector<V>::iterator DeviceValIterator;

        typedef typename thrust::pair<HostKeyIterator,  HostValIterator>   HostIteratorPair;
        typedef typename thrust::pair<DeviceKeyIterator,DeviceValIterator> DeviceIteratorPair;

        HostIteratorPair   h_last = thrust::unique_copy_by_key(h_keys.begin(), h_keys.end(), h_vals.begin(), h_keys_output.begin(), h_vals_output.begin());
        DeviceIteratorPair d_last = thrust::unique_copy_by_key(d_keys.begin(), d_keys.end(), d_vals.begin(), d_keys_output.begin(), d_vals_output.begin());

        ASSERT_EQUAL(h_last.first  - h_keys_output.begin(), d_last.first  - d_keys_output.begin());
        ASSERT_EQUAL(h_last.second - h_vals_output.begin(), d_last.second - d_vals_output.begin());
       
        size_t N = h_last.first - h_keys_output.begin();

        h_keys_output.resize(N);
        h_vals_output.resize(N);
        d_keys_output.resize(N);
        d_vals_output.resize(N);

        ASSERT_EQUAL(h_keys_output, d_keys_output);
        ASSERT_EQUAL(h_vals_output, d_vals_output);
    }
};
VariableUnitTest<TestUniqueCopyByKey, IntegralTypes> TestUniqueCopyByKeyInstance;
