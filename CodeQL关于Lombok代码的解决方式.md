# CodeQL关于Lombok代码的解决方式

## 两种方式生成数据库的差异

### DEMO1 手写Get、Set
```java
└─com
    └─keleth
        └─codeql
                RunDemo.java
                User.java

```
```java
package com.keleth.codeql;

public class RunDemo {
    public static void main(String[] args) {
        User user = new User();
        user.setUsername("李四");
        user.setFullname("法外狂徒张三");
        user.setLovemake("敲代码");
        user.setSex("男");
        user.setAge(18);
        System.out.println(user.toString());
    }
}

```
```java
package com.keleth.codeql;

public class User {
    private String username;
    private String fullname;
    private String lovemake;
    private String sex;
    private int age;

    @Override
    public String toString() {
        return "User{" +
        "username='" + username + '\'' +
        ", fullname='" + fullname + '\'' +
        ", lovemake='" + lovemake + '\'' +
        ", sex='" + sex + '\'' +
        ", age=" + age +
        '}';
    }
    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        User user = (User) o;
        if (age != user.age) return false;
        if (username != null ? !username.equals(user.username) : user.username != null) return false;
        if (fullname != null ? !fullname.equals(user.fullname) : user.fullname != null) return false;
        if (lovemake != null ? !lovemake.equals(user.lovemake) : user.lovemake != null) return false;
        return sex != null ? sex.equals(user.sex) : user.sex == null;
    }
    @Override
    public int hashCode() {
        int result = username != null ? username.hashCode() : 0;
        result = 31 * result + (fullname != null ? fullname.hashCode() : 0);
        result = 31 * result + (lovemake != null ? lovemake.hashCode() : 0);
        result = 31 * result + (sex != null ? sex.hashCode() : 0);
        result = 31 * result + age;
        return result;
    }
    public String getUsername() {return username;}
    public void setUsername(String username) {this.username = username;}
    public String getFullname() {return fullname;}
    public void setFullname(String fullname) {this.fullname = fullname;}
    public String getLovemake() {return lovemake;}
    public void setLovemake(String lovemake) {this.lovemake = lovemake;}
    public String getSex() {return sex;}
    public void setSex(String sex) {this.sex = sex;}
    public int getAge() {return age;}
    public void setAge(int age) {this.age = age;}
}
```
现在使用CodeQL生成数据库
```java
 codeql database create codeqlDemo1DB --language=java --source-root=./ --command="mvn clean install" 
```
在生成的数据库中，发现所有java文件被正常解析到数据库内
![image.png](https://cdn.nlark.com/yuque/0/2024/png/1348791/1707011371483-7a5aa22a-bb0a-46b1-b18c-14fb9853bc6a.png#averageHue=%23f5f4f3&clientId=u44a1e4e2-5fef-4&from=paste&height=227&id=ua51ff582&originHeight=340&originWidth=1233&originalType=binary&ratio=1.5&rotation=0&showTitle=false&size=31147&status=done&style=none&taskId=ub1289144-a2aa-4a1f-83e3-413d0b924f8&title=&width=822)

### DEMO2 LomBok
```java
└─com
    └─keleth
        └─codeql
                RunDemo.java
                User.java
```
```xml
<dependencies>
  <dependency>
    <groupId>org.projectlombok</groupId>
    <artifactId>lombok</artifactId>
    <version>1.18.24</version>
  </dependency>
</dependencies>
```
```java
package com.keleth.codeql;

import lombok.Data;

@Data
public class User {
    private String username;
    private String fullname;
    private String lovemake;
    private String sex;
    private int age;
}
```
```java
package com.keleth.codeql;

public class RunDemo {
    public static void main(String[] args) {
        User user = new User();
        user.setUsername("李四");
        user.setFullname("法外狂徒张三");
        user.setLovemake("敲代码");
        user.setSex("男");
        user.setAge(18);
        System.out.println(user.toString());
    }
}
```
创建CodeQL数据库
```java
 codeql database create codeqlDemo1DB --language=java --source-root=./ --command="mvn clean install"
```
在创建完成的数据库内，未将使用@Data注释的Lombok代码进行编译，关于这个问题，在github的CodeQL issue有解释，跟进看一下[https://github.com/github/codeql/issues/4984](https://github.com/github/codeql/issues/4984)
![image.png](https://cdn.nlark.com/yuque/0/2024/png/1348791/1707011782968-72bd654b-241b-4658-a2e8-bb6e7e46bc11.png#averageHue=%23f3f1ef&clientId=u44a1e4e2-5fef-4&from=paste&height=188&id=uced12ed9&originHeight=282&originWidth=1200&originalType=binary&ratio=1.5&rotation=0&showTitle=false&size=26260&status=done&style=none&taskId=u4254c7a7-dfab-492d-98cc-41a31163993&title=&width=800)

## 针对Lombok代码无法被正常解析的解决方式
### 方式一：使用Get、Set方式重写代码
参考[CodeQL关于Lombok代码的解决方式](https://www.yuque.com/u1106830/qognmy/hmz2g34l6qgvomdh) DEMO1 手写Get、Set
### 方式二：在代码被CodeQL编译采集的前一步，对Lombok代码进行还原
参考[https://github.com/github/codeql/issues/4984](https://github.com/github/codeql/issues/4984)
将lombok.jar文件放入到项目根目录，然后运行，解码文件
```java
java -jar "lombok.jar" delombok -n --onlyChanged . -d "delombok"
```
然后使用命令，将解码重写后的文件，再次写入到src路径中
```java
Windows
xcopy .\delombok\src .\src /E /I /Y

Linux
cp -r "delombok/." "./"
```
然后删除delombok目录即可，重新进行数据库编译，即可得到完成的项目数据库
### 方式三：更新CodeQL版本
CodeQL后续对Lombok代码进行了优化，现在的CodeQL已支持直接编译Lombok代码

在GitHub Enterprise Server 3.11+ 与CodeQL CLI 2.14.4+版本中已启用对Lombok代码的支持，详情见下连接
[Code scanning with CodeQL improves support for Java codebases that use Project Lombok](https://github.blog/changelog/2023-09-01-code-scanning-with-codeql-improves-support-for-java-codebases-that-use-project-lombok/)
