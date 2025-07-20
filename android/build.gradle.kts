// 所有项目的仓库配置
allprojects {
    repositories {
        // 阿里云谷歌镜像
        maven { 
            url = uri("https://maven.aliyun.com/repository/google") 
        }
        
        // 阿里云公共仓库
        maven { 
            url = uri("https://maven.aliyun.com/repository/public") 
        }
        
        // 网易镜像
        maven { 
            url = uri("https://mirrors.163.com/maven/repository/maven-public/") 
        }
        
        // 腾讯云Flutter镜像
        maven { 
            url = uri("https://mirrors.cloud.tencent.com/flutter/download.flutter.io") 
        }
        
        // 默认Google仓库
        google()
    }
}
val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
