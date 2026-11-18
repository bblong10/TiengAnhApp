-- CreateEnum
CREATE TYPE "QuestionType" AS ENUM ('MULTIPLE_CHOICE', 'FILL_BLANK');

-- CreateTable
CREATE TABLE "QuizQuestion" (
    "id" TEXT NOT NULL,
    "lessonId" TEXT NOT NULL,
    "question" TEXT NOT NULL,
    "type" "QuestionType" NOT NULL DEFAULT 'MULTIPLE_CHOICE',
    "options" TEXT[] DEFAULT ARRAY[]::TEXT[],
    "correctAnswer" TEXT NOT NULL,
    "explanation" TEXT,
    "order" INTEGER NOT NULL DEFAULT 1,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "QuizQuestion_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "QuizAttempt" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "lessonId" TEXT NOT NULL,
    "correctAnswers" INTEGER NOT NULL,
    "totalQuestions" INTEGER NOT NULL,
    "score" INTEGER NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "QuizAttempt_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "QuizQuestion_lessonId_idx" ON "QuizQuestion"("lessonId");

-- CreateIndex
CREATE UNIQUE INDEX "QuizQuestion_lessonId_order_key" ON "QuizQuestion"("lessonId", "order");

-- CreateIndex
CREATE INDEX "QuizAttempt_userId_idx" ON "QuizAttempt"("userId");

-- CreateIndex
CREATE INDEX "QuizAttempt_lessonId_idx" ON "QuizAttempt"("lessonId");

-- AddForeignKey
ALTER TABLE "QuizQuestion" ADD CONSTRAINT "QuizQuestion_lessonId_fkey" FOREIGN KEY ("lessonId") REFERENCES "Lesson"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "QuizAttempt" ADD CONSTRAINT "QuizAttempt_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "QuizAttempt" ADD CONSTRAINT "QuizAttempt_lessonId_fkey" FOREIGN KEY ("lessonId") REFERENCES "Lesson"("id") ON DELETE CASCADE ON UPDATE CASCADE;
