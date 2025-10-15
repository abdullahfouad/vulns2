#!/bin/bash
set -euo pipefail

echo "Creating multi-subproject Gradle project in current directory: $(pwd)"
echo "WARNING: this will create or overwrite settings.gradle, build.gradle, app/, lib/ in this directory."
read -p "Continue? (y/N) " confirm

# convert to lowercase manually (POSIX-compatible)
confirm_lower=$(echo "$confirm" | tr '[:upper:]' '[:lower:]')
if [ "$confirm_lower" != "y" ]; then
  echo "Aborted."
  exit 1
fi

# create subproject folders
mkdir -p app lib

# settings.gradle
cat > settings.gradle <<'EOF'
rootProject.name = 'multi-vuln-project'
include 'app', 'lib'
EOF

# Root build.gradle
cat > build.gradle <<'EOF'
plugins {
    id 'java'
}

allprojects {
    group = 'com.example'
    version = '1.0.0'

    repositories {
        mavenCentral()
    }

    // Intentionally vulnerable dependencies
    dependencies {
        implementation 'commons-collections:commons-collections:3.2.1'
        implementation 'org.apache.logging.log4j:log4j-core:2.13.0'
        implementation 'com.fasterxml.jackson.core:jackson-databind:2.9.9'
        implementation 'com.google.guava:guava:23.0'
        implementation 'commons-io:commons-io:2.4'
        implementation 'xerces:xercesImpl:2.11.0'
    }
}

subprojects {
    apply plugin: 'java'

    sourceCompatibility = JavaVersion.VERSION_1_8
    targetCompatibility = JavaVersion.VERSION_1_8

    dependencies {
        testImplementation 'junit:junit:4.12'
    }
}
EOF

# app/build.gradle
cat > app/build.gradle <<'EOF'
plugins {
    id 'java'
}

dependencies {
    implementation project(':lib')

    // app-specific old dependencies
    implementation 'com.google.guava:guava:18.0'
    implementation 'org.springframework:spring-web:4.3.0.RELEASE'
    implementation 'org.apache.httpcomponents:httpclient:4.3.6'
    testImplementation 'org.mockito:mockito-core:1.10.19'
}
EOF

# lib/build.gradle
cat > lib/build.gradle <<'EOF'
plugins {
    id 'java'
}

dependencies {
    // lib-specific old dependencies
    implementation 'com.fasterxml.jackson.core:jackson-databind:2.8.9'
    implementation 'org.codehaus.jackson:jackson-mapper-asl:1.9.13'
    implementation 'org.apache.commons:commons-lang3:3.1'
    implementation 'org.slf4j:slf4j-api:1.7.12'
    testImplementation 'junit:junit:4.11'
}
EOF

echo ""
echo "✅ Project files created in $(pwd):"
echo "  - settings.gradle"
echo "  - build.gradle"
echo "  - app/build.gradle"
echo "  - lib/build.gradle"
echo ""
echo "To build:"
echo "  gradle wrapper --gradle-version 7.6   # optional"
echo "  ./gradlew build   # or gradle build"
