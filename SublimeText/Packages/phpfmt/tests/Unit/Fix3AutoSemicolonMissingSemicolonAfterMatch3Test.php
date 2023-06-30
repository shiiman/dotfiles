<?php

use PHPUnit\Framework\TestCase;

class Fix3AutoSemicolonMissingSemicolonAfterMatch3Test extends TestCase
{
    public function testItWorks()
    {
        if (PHP_VERSION_ID < 80000) {
            $this->markTestSkipped();
        }

        exec("php " . __DIR__ . "/../../fmt.stub.php --passes=AutoSemicolon -o=- " . __DIR__ . '/fixtures/nine.txt', $output);

        $file = file_get_contents(__DIR__ . '/fixtures/nine.php');

        if (strtoupper(substr(PHP_OS, 0, 3)) === 'WIN') {
            $output = explode("\n", implode(PHP_EOL, $output));
        }

        $this->assertSame($file, implode("\n", $output));
    }
}
