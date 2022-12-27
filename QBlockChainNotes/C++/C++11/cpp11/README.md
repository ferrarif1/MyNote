# C++11/14/17 �������ܽ�


- initializer_list

```
	std::vector<int> vctInts({92, 12, 39, 46, 92, 84, -1, 0, -234});
```

- auto 

```
	std::vector<int> vctInts({92, 12, 39, 46, 92, 84, -1, 0, -234});
	for (const auto& item : vctInts)
	{
		std::cout << item << std::endl;
	}

```

- decltype

����ģ�庯���Ĳ���������������
```cpp
template <typename T, typename U>
auto MyFunc(T t, U u) -> decltype(t + u)
{
	return t + u;
}

```

���ڶ�lambda���������Զ��Ƶ�

```cpp
	auto func = [](int a, double b, const std::string& strTmp)->std::string {
		boost::format fmt("%1%  %2%  %3%");
		fmt % a% b% strTmp;
		return fmt.str();
	};

	/*
	auto func2 = [](int a, double b, const std::string& strTmp)->std::string {
		char buf[1024] = { 0 };
		memset(buf, 0, sizeof(buf));
		sprintf_s(buf, "%d %.8f %s", a, b, strTmp.c_str());
		return std::string(buf);
	};
	*/

	std::map<int, decltype(func)> fucMap;

	fucMap.insert( std::make_pair(0,   func) );
	//fucMap.insert( std::make_pair(1, );

	auto it = fucMap.find(0);
	BOOST_CHECK_EQUAL( fucMap.end()== it, false);
	std::cout << it->second(10, 1.23, std::string("hello")) << std::endl;

```

- override �� final

override ������������д�����麯��
final ��������һ������,����һ�����ֹ���̳�; ���������麯��ʱ, �����麯�����ܱ���д




- �����������ͺ��� (����ģ�庯��)

- ģ�����:  using

```cpp

typedef std::vector<std::map<std::string, std::string>>::iterator  itMaps;
using itMaps = std::vector<std::map<std::string, std::string>>::iterator  ;

```

using��������ģ��ı�������, typedef �򲻿���
```cpp
template<typename T>
using it12Items = std::array<T, 12>;   

```


- nullptr
����ȡ��  `NULL`
```cpp

0 == nullptr;  //true
NULL == nullptr;  //true


```


- ����ָ��

```
shared_ptr
unique_ptr
weak_ptr
```



- �쳣�淶  

```cpp

foo()noexcept
foo()noexcept(false)
foo()noexcept(true)


```


- explicit

C++11֮ǰ�����Ƶ��������Ĺ��캯������ʽת��
C+++11��ʼ�����ڵ��������Ĺ��캯��



- �ɱ����ģ��
һ���õݹ�ķ�ʽ�𲽼��ٲ����ĸ��� , �ݹ���ֹ��0������

```

//�ݹ����
void XPrint()
{
}


template< typename T, typename ...Types>
void XPrint(const T& first,  const Types&... otherArgs)
{
	PlainPrint(first);
	XPrint( otherArgs... );
}



BOOST_AUTO_TEST_CASE(test_variadic_templates)
{
	std::cout << "hello  ............" << std::endl;

	XPrint(2, 5.231, std::string("hello"), "niuniu", std::complex(5, 1));

}

```


- ��ֵ���ú��ƶ�����

ע���Լ�ʵ���ƶ�����(move ctor)��ʱ��(��ָ��), ��βʱ��Ҫ����move�Ķ����ָ������ΪNULL

```

std::vector<std::string> vctInts;
vctInts.push_back(std::move( std::string("hello") ));

```

- ԭ���ַ���֧��

  ```c++
  //std::string  strFilePath1 = "C:\\Program Files (x86)\\Tencent\\QQ\\gf-config.xml"; //ok
  
  //std::string  strFilePath1 = R"(D:\gradle-6.0-bin.zip)"; //ok
  
  std::string  strFilePath1 = R"(C:\Program Files (x86)\Tencent\QQ\gf-config.xml)"; //ok
  
  std::filesystem::path p1( strFilePath1 ); //filesystem�� C++17��׼
  if (filesystem::exists(p1)){
      std::cout << "exists" << std::endl;
  }else{
      std::cout << "not exists" << std::endl;
  }
  
  std::ifstream infstream( strFilePath1, ios::in | ios::binary);
  if(infstream.is_open())
  {
      char buf[1024] { 0 };
      memset(buf, 0, sizeof(buf));
  
      while (!infstream.eof())
      {
          infstream.getline(buf, 1024);
          std::cout << buf << std::endl;
      }
  
      infstream.close();
  }
  else
  {
      std::cout << "open file failed." << std::endl;
  }
  ```

  


- filesystem �ļ�ϵͳ

  


- chrono  ʱ��
- regex ������ʽ



��������, ���� [C++11�������](./C++11�������.md) ��������

- atomic ԭ�Ӳ���

  >  https://en.cppreference.com/w/cpp/atomic
  >
  > ����std::memory_order: https://www.cnblogs.com/lizhanzhe/p/10893016.html

- std::thread


- std::mutex 
- std::future 
- std::atomic
- std::async

