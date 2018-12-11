node {
    stage("Checkout") {
        checkout scm
    }
    stage("Testing Image and publishing") {
        sh "./gradlew test pushDockerImage"
    }
}